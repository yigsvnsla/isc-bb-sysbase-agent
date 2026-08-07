package com.isc.bb.sysbase_agent.security;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.aop.support.AopUtils;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Aspect
@Component
public class ToolSecurityAspect {

    private final ToolAccessGuard guard;

    public ToolSecurityAspect(ToolAccessGuard guard) {
        this.guard = guard;
    }

    @Around("execution(@org.springframework.ai.tool.annotation.Tool * com.isc.bb.sysbase_agent.tools..*(..))"
            + " || execution(@org.springframework.ai.tool.annotation.Tool * com.isc.bb.sysbase_agent.loader..*(..))")
    public Object guardTool(ProceedingJoinPoint pjp) throws Throwable {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        String role = null;
        if (auth != null) {
            for (GrantedAuthority ga : auth.getAuthorities()) {
                var a = ga.getAuthority();
                if (a != null && a.startsWith("ROLE_")) {
                    role = a.substring("ROLE_".length());
                    break;
                }
            }
        }
        var signature = (MethodSignature) pjp.getSignature();
        var method = AopUtils.getMostSpecificMethod(signature.getMethod(), pjp.getTarget().getClass());
        var tool = method.getAnnotation(org.springframework.ai.tool.annotation.Tool.class);
        var toolName = (tool != null && !tool.name().isBlank()) ? tool.name() : method.getName();
        if (!guard.canInvoke(role, toolName)) {
            throw new SecurityException("Tool '" + toolName + "' no permitida para rol: " + role);
        }
        return pjp.proceed();
    }
}
