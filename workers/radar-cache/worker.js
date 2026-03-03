export default {
  async fetch(request) {
    const url = new URL(request.url);
    const originUrl = 'https://mesonet.agron.iastate.edu' + url.pathname;

    const cache = caches.default;
    const cacheKey = new Request(originUrl);
    let response = await cache.match(cacheKey);

    if (!response) {
      response = await fetch(originUrl, {
        headers: { 'User-Agent': 'Heather Weather App' },
      });
      response = new Response(response.body, response);
      // Cache for 5 minutes (IEM updates every 5 min)
      response.headers.set('Cache-Control', 'public, max-age=300');
      await cache.put(cacheKey, response.clone());
    }

    return response;
  },
};
