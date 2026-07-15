import { getViteConfig } from 'astro/config';

// Runs every other *.test.ts file under Node, with just enough Astro/Vite
// setup to import and render `.astro` components via the Container API.
// `configFile: false` deliberately skips loading astro.config.mjs: the
// @astrojs/cloudflare adapter it configures sets up a "workerd" prerender
// Vite environment that isn't compatible with plain Vitest (it crashes
// there — the adapter expects `astro dev`/`astro build`, not a test
// runner). Component tests don't need the adapter anyway. Worker/API logic
// tests use vitest.worker.config.ts instead, since that needs the real
// Workers runtime this config doesn't have.
export default getViteConfig(
	{
		test: {
			include: ['src/**/*.test.ts'],
			exclude: ['src/**/*.worker.test.ts']
		}
	},
	{ configFile: false }
);
