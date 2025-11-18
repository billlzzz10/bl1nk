/**
 * Parse a boolean-like environment variable value.
 * Accepts case-insensitive string "true" as true; everything else is false.
 * Undefined or empty values are treated as false.
 */
export function parseBooleanFlag(value) {
    return String(value || '').toLowerCase() === 'true';
}
