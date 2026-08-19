package com.isc.bb.sysbase_agent.db;

import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Config de conexiones multi-motor (F1).
 *
 * app.databases.default-engine: nombre de motor por defecto (default "postgres")
 * app.databases.connections.<nombre>.{engine,url,username,password,enabled}
 */
@Component
@ConfigurationProperties(prefix = "app.databases")
public class DbConnectionsProperties {

    private String defaultEngine = "postgres";

    private Map<String, ConnectionProps> connections = new LinkedHashMap<>();

    public String getDefaultEngine() {
        return defaultEngine;
    }

    public void setDefaultEngine(String defaultEngine) {
        this.defaultEngine = defaultEngine;
    }

    public Map<String, ConnectionProps> getConnections() {
        return connections;
    }

    public void setConnections(Map<String, ConnectionProps> connections) {
        this.connections = connections;
    }

    public static class ConnectionProps {
        private String engine;
        private String url;
        private String username;
        private String password;
        private boolean enabled = true;

        public String getEngine() {
            return engine;
        }

        public void setEngine(String engine) {
            this.engine = engine;
        }

        public String getUrl() {
            return url;
        }

        public void setUrl(String url) {
            this.url = url;
        }

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }

        public boolean isEnabled() {
            return enabled;
        }

        public void setEnabled(boolean enabled) {
            this.enabled = enabled;
        }
    }
}
