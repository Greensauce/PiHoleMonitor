// Pi-hole API helper functions
// Supports both Pi-hole v5 (legacy API) and v6 (REST API with app password)
.pragma library

var debugMode = true; // Set to false to disable console logging
var preferredApiVersion = null; // "v5" or "v6", set after first successful call

function log(message) {
    if (debugMode) {
        console.log("[Pi-hole Widget] " + message);
    }
}

// Main API functions - try preferred version first, fallback to the other
function getStatus(host, apiKey, callback) {
    log("Getting status from: " + host);
    
    // Validate inputs
    if (!host || host.trim() === "") {
        callback(false, { error: "Pi-hole IP address is empty" });
        return;
    }
    if (!apiKey || apiKey.trim() === "") {
        callback(false, { error: "App Password/API Key is empty" });
        return;
    }
    
    // If we know which API version works, try that first
    if (preferredApiVersion === "v6") {
        log("Preferring v6 API (learned from previous success)");
        tryV6Status(host, apiKey, function(v6Success, v6Response) {
            if (v6Success) {
                callback(true, v6Response);
            } else {
                log("v6 failed, trying v5 as fallback");
                tryV5Status(host, apiKey, callback);
            }
        });
    } else {
        // Default: try v5 first (simpler, more widely compatible)
        tryV5Status(host, apiKey, function(v5Success, v5Response) {
            if (v5Success) {
                preferredApiVersion = "v5";
                log("v5 API succeeded, will prefer v5 in future");
                callback(true, v5Response);
            } else {
                log("v5 API failed: " + v5Response.error + ", trying v6...");
                // Try v6 API as fallback
                tryV6Status(host, apiKey, function(v6Success, v6Response) {
                    if (v6Success) {
                        preferredApiVersion = "v6";
                        log("v6 API succeeded, will prefer v6 in future");
                        callback(true, v6Response);
                    } else {
                        log("v6 API also failed: " + v6Response.error);
                        // Both failed, return most specific error
                        callback(false, { 
                            error: "Cannot connect to Pi-hole.\nCheck IP address and App Password.\n\nDetails:\n" + v5Response.error
                        });
                    }
                });
            }
        });
    }
}

function disable(host, apiKey, seconds, callback) {
    log("Disabling Pi-hole for " + seconds + " seconds");
    
    // If we know which API version works, try that first
    if (preferredApiVersion === "v6") {
        tryV6Disable(host, apiKey, seconds, function(v6Success, v6Response) {
            if (v6Success) {
                callback(true, v6Response);
            } else {
                log("v6 disable failed, trying v5 as fallback");
                tryV5Disable(host, apiKey, seconds, callback);
            }
        });
    } else {
        // Try v5 first
        tryV5Disable(host, apiKey, seconds, function(v5Success, v5Response) {
            if (v5Success) {
                log("v5 disable succeeded");
                callback(true, v5Response);
            } else {
                log("v5 disable failed, trying v6...");
                tryV6Disable(host, apiKey, seconds, function(v6Success, v6Response) {
                    if (v6Success) {
                        log("v6 disable succeeded");
                        callback(true, v6Response);
                    } else {
                        callback(false, { error: "Failed to disable: " + v6Response.error });
                    }
                });
            }
        });
    }
}

function enable(host, apiKey, callback) {
    log("Enabling Pi-hole");
    
    // If we know which API version works, try that first
    if (preferredApiVersion === "v6") {
        tryV6Enable(host, apiKey, function(v6Success, v6Response) {
            if (v6Success) {
                callback(true, v6Response);
            } else {
                log("v6 enable failed, trying v5 as fallback");
                tryV5Enable(host, apiKey, callback);
            }
        });
    } else {
        // Try v5 first
        tryV5Enable(host, apiKey, function(v5Success, v5Response) {
            if (v5Success) {
                log("v5 enable succeeded");
                callback(true, v5Response);
            } else {
                log("v5 enable failed, trying v6...");
                tryV6Enable(host, apiKey, function(v6Success, v6Response) {
                    if (v6Success) {
                        log("v6 enable succeeded");
                        callback(true, v6Response);
                    } else {
                        callback(false, { error: "Failed to enable: " + v6Response.error });
                    }
                });
            }
        });
    }
}

// ========== Pi-hole v5 Legacy API (api.php) ==========

function tryV5Status(host, apiKey, callback) {
    var xhr = new XMLHttpRequest();
    var url = "http://" + host + "/admin/api.php?status&auth=" + encodeURIComponent(apiKey);
    
    log("v5 status URL: " + url.replace(apiKey, "***"));
    
    xhr.timeout = 5000; // 5 second timeout
    
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            log("v5 status HTTP status: " + xhr.status);
            if (xhr.status === 200) {
                try {
                    var response = JSON.parse(xhr.responseText);
                    log("v5 status response: " + JSON.stringify(response));
                    if (response.status) {
                        callback(true, response);
                    } else {
                        callback(false, { error: "No status field in response" });
                    }
                } catch (e) {
                    log("v5 parse error: " + e);
                    callback(false, { error: "Failed to parse JSON: " + e });
                }
            } else if (xhr.status === 0) {
                callback(false, { error: "Network error - cannot reach Pi-hole at " + host });
            } else if (xhr.status === 401) {
                callback(false, { error: "Authentication failed - check your App Password/API Key" });
            } else {
                callback(false, { error: "HTTP " + xhr.status });
            }
        }
    };
    
    xhr.ontimeout = function() {
        log("v5 status timeout");
        callback(false, { error: "Timeout connecting to Pi-hole" });
    };
    
    xhr.onerror = function() {
        log("v5 status network error");
        callback(false, { error: "Network error - check Pi-hole IP address" });
    };
    
    try {
        xhr.open("GET", url);
        xhr.send();
    } catch (e) {
        log("v5 exception: " + e);
        callback(false, { error: "Exception: " + e });
    }
}

function tryV5Disable(host, apiKey, seconds, callback) {
    var xhr = new XMLHttpRequest();
    var url = "http://" + host + "/admin/api.php?disable=" + seconds + "&auth=" + encodeURIComponent(apiKey);
    
    log("v5 disable URL: " + url.replace(apiKey, "***"));
    
    xhr.timeout = 5000;
    
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var response = JSON.parse(xhr.responseText);
                    callback(true, response);
                } catch (e) {
                    callback(false, { error: "Failed to parse response" });
                }
            } else {
                callback(false, { error: "HTTP " + xhr.status });
            }
        }
    };
    
    xhr.ontimeout = function() {
        callback(false, { error: "Timeout" });
    };
    
    xhr.onerror = function() {
        callback(false, { error: "Network error" });
    };
    
    try {
        xhr.open("GET", url);
        xhr.send();
    } catch (e) {
        callback(false, { error: "Exception: " + e });
    }
}

function tryV5Enable(host, apiKey, callback) {
    var xhr = new XMLHttpRequest();
    var url = "http://" + host + "/admin/api.php?enable&auth=" + encodeURIComponent(apiKey);
    
    log("v5 enable URL: " + url.replace(apiKey, "***"));
    
    xhr.timeout = 5000;
    
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var response = JSON.parse(xhr.responseText);
                    callback(true, response);
                } catch (e) {
                    callback(false, { error: "Failed to parse response" });
                }
            } else {
                callback(false, { error: "HTTP " + xhr.status });
            }
        }
    };
    
    xhr.ontimeout = function() {
        callback(false, { error: "Timeout" });
    };
    
    xhr.onerror = function() {
        callback(false, { error: "Network error" });
    };
    
    try {
        xhr.open("GET", url);
        xhr.send();
    } catch (e) {
        callback(false, { error: "Exception: " + e });
    }
}

// ========== Pi-hole v6 REST API ==========

var sessionId = null;
var sessionExpiry = 0;

function tryV6Status(host, password, callback) {
    authenticateV6(host, password, function(authSuccess, authResponse) {
        if (!authSuccess) {
            callback(false, authResponse);
            return;
        }
        
        var xhr = new XMLHttpRequest();
        var url = "http://" + host + "/api/dns/blocking";
        
        log("v6 status URL: " + url);
        xhr.timeout = 5000;
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                log("v6 status HTTP status: " + xhr.status);
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        log("v6 status response: " + JSON.stringify(response));
                        
                        // v6 returns "enabled"/"disabled" as string, or true/false as boolean
                        var isBlocking = (response.blocking === "enabled" || response.blocking === true);
                        
                        // Extract timer if present
                        var timer = response.timer || 0;
                        
                        // Convert v6 format to v5-compatible format
                        var converted = {
                            status: isBlocking ? "enabled" : "disabled",
                            blocking: isBlocking,
                            timer: timer
                        };
                        
                        log("v6 converted response: blocking=" + isBlocking + ", timer=" + timer);
                        callback(true, converted);
                    } catch (e) {
                        log("v6 parse error: " + e);
                        callback(false, { error: "Failed to parse v6 response" });
                    }
                } else if (xhr.status === 0) {
                    callback(false, { error: "Cannot reach v6 API endpoint" });
                } else {
                    callback(false, { error: "v6 HTTP " + xhr.status });
                }
            }
        };
        
        xhr.ontimeout = function() {
            callback(false, { error: "v6 timeout" });
        };
        
        xhr.onerror = function() {
            callback(false, { error: "v6 network error" });
        };
        
        try {
            xhr.open("GET", url);
            xhr.setRequestHeader("sid", sessionId);
            xhr.send();
        } catch (e) {
            callback(false, { error: "v6 exception: " + e });
        }
    });
}

function tryV6Disable(host, password, seconds, callback) {
    authenticateV6(host, password, function(authSuccess, authResponse) {
        if (!authSuccess) {
            log("v6 disable auth failed");
            callback(false, authResponse);
            return;
        }
        
        log("v6 disable: authenticated, disabling for " + seconds + " seconds");
        
        var xhr = new XMLHttpRequest();
        var url = "http://" + host + "/api/dns/blocking";
        
        var payload = { blocking: false };
        if (seconds > 0) {
            payload.timer = seconds;
        }
        
        log("v6 disable URL: " + url);
        log("v6 disable payload: " + JSON.stringify(payload));
        
        xhr.timeout = 5000;
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                log("v6 disable HTTP status: " + xhr.status);
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        log("v6 disable response: " + JSON.stringify(response));
                        callback(true, response);
                    } catch (e) {
                        log("v6 disable parse error: " + e);
                        callback(false, { error: "Failed to parse v6 response" });
                    }
                } else {
                    log("v6 disable failed with HTTP " + xhr.status);
                    log("v6 disable response text: " + xhr.responseText);
                    callback(false, { error: "v6 HTTP " + xhr.status + ": " + xhr.responseText });
                }
            }
        };
        
        xhr.ontimeout = function() {
            log("v6 disable timeout");
            callback(false, { error: "v6 timeout" });
        };
        
        xhr.onerror = function() {
            log("v6 disable network error");
            callback(false, { error: "v6 network error" });
        };
        
        try {
            xhr.open("POST", url);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.setRequestHeader("sid", sessionId);
            xhr.send(JSON.stringify(payload));
        } catch (e) {
            log("v6 disable exception: " + e);
            callback(false, { error: "v6 exception: " + e });
        }
    });
}

function tryV6Enable(host, password, callback) {
    authenticateV6(host, password, function(authSuccess, authResponse) {
        if (!authSuccess) {
            log("v6 enable auth failed");
            callback(false, authResponse);
            return;
        }
        
        log("v6 enable: authenticated, enabling Pi-hole");
        
        var xhr = new XMLHttpRequest();
        var url = "http://" + host + "/api/dns/blocking";
        
        log("v6 enable URL: " + url);
        
        xhr.timeout = 5000;
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                log("v6 enable HTTP status: " + xhr.status);
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        log("v6 enable response: " + JSON.stringify(response));
                        callback(true, response);
                    } catch (e) {
                        log("v6 enable parse error: " + e);
                        callback(false, { error: "Failed to parse v6 response" });
                    }
                } else {
                    log("v6 enable failed with HTTP " + xhr.status);
                    log("v6 enable response text: " + xhr.responseText);
                    callback(false, { error: "v6 HTTP " + xhr.status + ": " + xhr.responseText });
                }
            }
        };
        
        xhr.ontimeout = function() {
            log("v6 enable timeout");
            callback(false, { error: "v6 timeout" });
        };
        
        xhr.onerror = function() {
            log("v6 enable network error");
            callback(false, { error: "v6 network error" });
        };
        
        try {
            xhr.open("POST", url);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.setRequestHeader("sid", sessionId);
            xhr.send(JSON.stringify({ blocking: true }));
        } catch (e) {
            log("v6 enable exception: " + e);
            callback(false, { error: "v6 exception: " + e });
        }
    });
}

function authenticateV6(host, password, callback) {
    // Check if we have a valid session
    var now = Date.now();
    if (sessionId && sessionExpiry > now) {
        log("Using cached v6 session");
        callback(true, { sid: sessionId });
        return;
    }
    
    log("Authenticating v6...");
    var xhr = new XMLHttpRequest();
    var url = "http://" + host + "/api/auth";
    
    xhr.timeout = 5000;
    
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            log("v6 auth HTTP status: " + xhr.status);
            if (xhr.status === 200) {
                try {
                    var response = JSON.parse(xhr.responseText);
                    log("v6 auth response: " + JSON.stringify(response));
                    if (response.session && response.session.sid) {
                        sessionId = response.session.sid;
                        var validity = response.session.validity || 300;
                        sessionExpiry = now + (validity * 1000);
                        log("v6 session established");
                        callback(true, response);
                    } else {
                        sessionId = null;
                        callback(false, { error: "No session ID in v6 auth response" });
                    }
                } catch (e) {
                    log("v6 auth parse error: " + e);
                    callback(false, { error: "Failed to parse v6 auth response" });
                }
            } else if (xhr.status === 0) {
                callback(false, { error: "Cannot reach v6 auth endpoint" });
            } else if (xhr.status === 401) {
                callback(false, { error: "v6 authentication failed - wrong password" });
            } else {
                callback(false, { error: "v6 auth HTTP " + xhr.status });
            }
        }
    };
    
    xhr.ontimeout = function() {
        log("v6 auth timeout");
        callback(false, { error: "v6 auth timeout" });
    };
    
    xhr.onerror = function() {
        log("v6 auth network error");
        callback(false, { error: "v6 auth network error" });
    };
    
    try {
        xhr.open("POST", url);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(JSON.stringify({ password: password }));
    } catch (e) {
        log("v6 auth exception: " + e);
        callback(false, { error: "v6 auth exception: " + e });
    }
}

// ========== Utility Functions ==========

function formatTime(seconds) {
    if (seconds <= 0) return "Disabled";
    
    var hours = Math.floor(seconds / 3600);
    var minutes = Math.floor((seconds % 3600) / 60);
    var secs = seconds % 60;
    
    if (hours > 0) {
        return hours + "h " + minutes + "m";
    } else if (minutes > 0) {
        return minutes + "m " + secs + "s";
    } else {
        return secs + "s";
    }
}
