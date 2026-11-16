// Tiny structured logger (stdout). Keeps the codebase free of stray
// console.log calls in business logic; use these helpers instead.
export const logger = {
  info: (msg: string, meta?: unknown) => {
    // eslint-disable-next-line no-console
    console.log(JSON.stringify({ level: 'info', msg, ...(meta ? { meta } : {}) }));
  },
  warn: (msg: string, meta?: unknown) => {
    // eslint-disable-next-line no-console
    console.warn(JSON.stringify({ level: 'warn', msg, ...(meta ? { meta } : {}) }));
  },
  error: (msg: string, meta?: unknown) => {
    // eslint-disable-next-line no-console
    console.error(JSON.stringify({ level: 'error', msg, ...(meta ? { meta } : {}) }));
  },
};
