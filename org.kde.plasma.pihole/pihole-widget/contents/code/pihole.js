/**
 * Pi-hole Plasma Widget - API Client
 * Copyright (C) 2024-2025 Bryan Greenaway
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 */

.pragma library

var sessionId = null;
var sessionExpiry = 0;
var REQUEST_TIMEOUT = 5000;
var SESSION_LIFETIME = 300000; // 5 minutes in milliseconds

function formatTime(seconds) {
    if (seconds <= 0) return "0s";
    var minutes = Math.floor(seconds / 60);
    var secs = Math.floor(seconds % 60);
    return minutes > 0 ? minutes + "m " + secs + "s" : seconds + "s";
}

function authenticate(host, password, callback) {
    var now = Date.now();
    if (sessionId && sessionExpiry > now) {
        callback(true, sessionId);
        return;
    }
    
    var xhr = new XMLHttpRequest();
    xhr.timeout = REQUEST_TIMEOUT;
    xhr.open("POST", "http://" + host + "/api/auth", true);
    xhr.setRequestHeader("Content-Type", "application/json");
    
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var response = JSON.parse(xhr.responseText);
                    if (response.session && response.session.sid) {
                        sessionId = response.session.sid;
                        sessionExpiry = now + SESSION_LIFETIME;
                        callback(true, sessionId);
                    } else {
                        callback(false, "No session in response");
                    }
                } catch (e) {
                    callback(false, "Invalid response");
                }
            } else {
                callback(false, xhr.status === 401 ? "Invalid App Password" : "Authentication failed");
            }
        }
    };
    
    xhr.ontimeout = function() { callback(false, "Connection timeout"); };
    xhr.onerror = function() { callback(false, "Network error"); };
    xhr.send(JSON.stringify({ password: password }));
}

function getStatus(host, password, callback) {
    if (!host || !password) {
        callback(false, { error: "Missing configuration" });
        return;
    }
    
    authenticate(host, password, function(success, sidOrError) {
        if (!success) {
            callback(false, { error: sidOrError });
            return;
        }
        
        var xhr = new XMLHttpRequest();
        xhr.timeout = REQUEST_TIMEOUT;
        xhr.open("GET", "http://" + host + "/api/dns/blocking", true);
        xhr.setRequestHeader("sid", sidOrError);
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        callback(true, {
                            status: (response.blocking === "enabled" || response.blocking === true) ? "enabled" : "disabled",
                            timer: response.timer || 0
                        });
                    } catch (e) {
                        callback(false, { error: "Invalid response" });
                    }
                } else {
                    callback(false, { error: "Request failed" });
                }
            }
        };
        
        xhr.ontimeout = function() { callback(false, { error: "Timeout" }); };
        xhr.onerror = function() { callback(false, { error: "Network error" }); };
        xhr.send();
    });
}

function setBlocking(host, password, enabled, seconds, callback) {
    authenticate(host, password, function(success, sidOrError) {
        if (!success) {
            callback(false);
            return;
        }
        
        var xhr = new XMLHttpRequest();
        xhr.timeout = REQUEST_TIMEOUT;
        xhr.open("POST", "http://" + host + "/api/dns/blocking", true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("sid", sidOrError);
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                callback(xhr.status === 200);
            }
        };
        
        xhr.ontimeout = function() { callback(false); };
        xhr.onerror = function() { callback(false); };
        
        var payload = { blocking: enabled };
        if (!enabled && seconds > 0) {
            payload.timer = seconds;
        }
        xhr.send(JSON.stringify(payload));
    });
}

function enable(host, password, callback) {
    setBlocking(host, password, true, 0, callback);
}

function disable(host, password, seconds, callback) {
    setBlocking(host, password, false, seconds, callback);
}
