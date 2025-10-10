'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "c68f6ea7f16ff33e63750f82be9d34f9",
"version.json": "d0eb564a69bb72ed1c194ffa2a7c2ac9",
"index.html": "ef1ae025597c47b89f31af75187a4761",
"/": "ef1ae025597c47b89f31af75187a4761",
"main.dart.js": "eb62a734f4911675b9cdcdc9a797d096",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"manifest.json": "42a435ffd67d702d54ef38265901a9e8",
"assets/AssetManifest.json": "535b49f7977ac3670dd0fd3b4328b143",
"assets/NOTICES": "a5d026368d2647d3c877ab91f2052cb3",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "c5ad6c8e1b2d17f951e74715c13a47e0",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "c0c58e8f7d658f17d6e49da02c74a646",
"assets/fonts/MaterialIcons-Regular.otf": "b3cef02184a70d1f7b678f7d11484f3b",
"assets/assets/images/wardrobe/iconstack.io%2520-%2520(Hanger).png": "3ba7a7990d017e479dc4203b3df022ef",
"assets/assets/images/post/bookmark.png": "a0d9c37e6798e340b5c2595ec5c4b664",
"assets/assets/images/post/Generic%2520avatar.png": "c74be6a30db95135c9e806c128b084f6",
"assets/assets/images/post/View.png": "a0458cb129386f84b588c1566c59a6d3",
"assets/assets/images/post/Share.png": "d3230cddc53272b64b0283993b45bf66",
"assets/assets/images/post/Wardrobe.png": "feccc00c5939e9777b22eb6e2c93c538",
"assets/assets/images/post/favorite.png": "0459cc0176ad857afdf0409ad3b9f6cb",
"assets/assets/images/homepage/carousel_template_image_1.png": "240b78be0431c81c891efca418c4a888",
"assets/assets/images/homepage/carousel_template_image_2.png": "240b78be0431c81c891efca418c4a888",
"assets/assets/images/signup/get_code.png": "61acc8308caf6131bc280daa3c518efe",
"assets/assets/images/signup/cancel.png": "383d276166c9afc114ce94f3a2680962",
"assets/assets/images/signup/folded_list_icon.png": "d4a4df2235c3916488b1a563dd863407",
"assets/assets/images/signup/Sign_up_tab%2520(1).png": "5fdff666521a44b715ac30819fbc5b1d",
"assets/assets/images/signup/unfolded_list_icon.png": "7c6a7be271316a485484b7ab53701ee7",
"assets/assets/images/navigation/Searchbar/Search.png": "1ca53c8dd96fd69f79c0086855bd7e91",
"assets/assets/images/navigation/Searchbar/Logo.png": "f02e24264b99af27f121068abdb134a5",
"assets/assets/images/navigation/Sign_up_tab.png": "a780f14a382eb869ca6724c8ee423118",
"assets/assets/images/navigation/shop_icon.png": "3340951563a2bff812de076b63f15731",
"assets/assets/images/navigation/Explore_tab.png": "a1edad4639f9450af16b2949163806fe",
"assets/assets/images/navigation/home_icon.png": "a6636595db6e4ae176ffef4abbb615bb",
"assets/assets/images/navigation/folded_list_icon.png": "d4a4df2235c3916488b1a563dd863407",
"assets/assets/images/navigation/book_icon.png": "1a55ea7044e151edab521e2c7aa79bf0",
"assets/assets/images/navigation/Wardrobe_icon.png": "62b7f1e1a3c8177238071baf94cc7a70",
"assets/assets/images/navigation/notifications.png": "dafbd7979cb72fcec65b3aba9892ab07",
"assets/assets/images/navigation/Driplix%2520Logo.png": "5ab040fee41c02ca0db85dfe4305efb5",
"assets/assets/images/navigation/Generic%2520avatar%2520(1).png": "c74be6a30db95135c9e806c128b084f6",
"assets/assets/images/navigation/unfolded_list_icon.png": "7c6a7be271316a485484b7ab53701ee7",
"assets/assets/images/navigation/try_on.png": "c73fc97f9357a00702c1ea4fcc7556dc",
"assets/assets/images/navigation/Sign_in_tab.png": "4e4178ed91a6a06506f9ca78c5e6bb43",
"assets/assets/images/logos/placeholder.txt": "84297dfe260bd69a549e8d4641fe7b55",
"assets/assets/images/signin/cancel.png": "383d276166c9afc114ce94f3a2680962",
"assets/assets/images/signin/folded_list_icon.png": "d4a4df2235c3916488b1a563dd863407",
"assets/assets/images/signin/Sign_in_tab%2520(1).png": "84cc97e9b81598cf8463e5d6b9e985d0",
"assets/assets/images/signin/unfolded_list_icon.png": "7c6a7be271316a485484b7ab53701ee7",
"assets/assets/images/icons/placeholder.txt": "3babefdc97b3d56a85f2f5f04b5ee5ae",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
