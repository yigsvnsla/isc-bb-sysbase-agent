package com.isc.bb.sysbase_agent.db;

/**
 * Contexto de motor por hilo de ejecución. Lo fija AgentService alrededor de
 * cada turno de chat; las tools de catálogo lo leen para resolver el motor.
 */
public final class EngineContext {

    private static final ThreadLocal<String> CURRENT = new ThreadLocal<>();

    private EngineContext() {
    }

    public static String current() {
        return CURRENT.get();
    }

    public static void set(String engine) {
        CURRENT.set(engine);
    }

    public static void clear() {
        CURRENT.remove();
    }
}
