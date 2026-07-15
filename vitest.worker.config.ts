import { cloudflareTest } from '@cloudflare/vitest-pool-workers';
import { defineConfig } from 'vitest/config';

// Runs *.worker.test.ts files inside the actual Workers runtime (workerd via
// Miniflare), not a Node mock — for testing Worker/API logic against real
// bindings. Astro component tests use vitest.astro.config.ts instead, since
// this pool can't run the Astro Container API.
export default defineConfig({
	plugins: [cloudflareTest({ wrangler: { configPath: './wrangler.jsonc' } })],
	test: {
		include: ['src/**/*.worker.test.ts']
	}
});
