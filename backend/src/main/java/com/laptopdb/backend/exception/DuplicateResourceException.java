package com.laptopdb.backend.exception;

public class DuplicateResourceException extends RuntimeException {

    private final String resourceName;
    private final String field;
    private final Object value;

    public DuplicateResourceException(String resourceName, String field, Object value) {
        super(resourceName + " already exists with " + field + ": " + value);
        this.resourceName = resourceName;
        this.field = field;
        this.value = value;
    }

    public String getResourceName() {
        return resourceName;
    }

    public String getField() {
        return field;
    }

    public Object getValue() {
        return value;
    }
}