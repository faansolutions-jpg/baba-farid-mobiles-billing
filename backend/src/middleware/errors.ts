// Typed API error. Throw these in services/routes; errorHandler turns them
// into the { ok:false, error } envelope with the right HTTP status.
export class ApiError extends Error {
  status: number;
  code: string;
  details?: unknown;

  constructor(status: number, message: string, code = 'ERROR', details?: unknown) {
    super(message);
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

export const badRequest = (msg: string, details?: unknown) =>
  new ApiError(400, msg, 'BAD_REQUEST', details);
export const unauthorized = (msg = 'Authentication required') =>
  new ApiError(401, msg, 'UNAUTHORIZED');
export const forbidden = (msg = 'You do not have permission for this action') =>
  new ApiError(403, msg, 'FORBIDDEN');
export const notFound = (msg = 'Record not found') =>
  new ApiError(404, msg, 'NOT_FOUND');
export const conflict = (msg: string, details?: unknown) =>
  new ApiError(409, msg, 'CONFLICT', details);
export const unprocessable = (msg: string, details?: unknown) =>
  new ApiError(422, msg, 'UNPROCESSABLE', details);
