import { experimental_AstroContainer as AstroContainer } from 'astro/container';
import { describe, expect, it } from 'vitest';
import Welcome from './Welcome.astro';

describe('Welcome', () => {
	it('renders a link to the Astro docs', async () => {
		const container = await AstroContainer.create();
		const result = await container.renderToString(Welcome);

		expect(result).toContain('Read our docs');
	});
});
