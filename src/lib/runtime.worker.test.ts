import { describe, expect, it } from 'vitest';

// Setup-verification test, not a feature test: proves *.worker.test.ts files
// actually run inside workerd (via @cloudflare/vitest-pool-workers), not a
// Node mock — `navigator.userAgent` is only "Cloudflare-Workers" there. Once
// real API routes/bindings exist, replace this with tests for them.
describe('workers runtime', () => {
	it('runs inside workerd', () => {
		expect(navigator.userAgent).toBe('Cloudflare-Workers');
	});
});
