'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "version.json": "87a633d8cad2d13e4edd21ca98a9049d",
"splash/img/light-2x.png": "f20a2a0ad3c2a0292f30c8acbfa11b8f",
"splash/img/dark-4x.png": "fa32a463461e847dfca0e958905bc108",
"splash/img/light-3x.png": "9e99ff516362b7755053180b3fa5dcde",
"splash/img/dark-3x.png": "9e99ff516362b7755053180b3fa5dcde",
"splash/img/light-4x.png": "fa32a463461e847dfca0e958905bc108",
"splash/img/dark-2x.png": "f20a2a0ad3c2a0292f30c8acbfa11b8f",
"splash/img/dark-1x.png": "f7d0d74353b5006581d93b0fe1644a12",
"splash/img/light-1x.png": "f7d0d74353b5006581d93b0fe1644a12",
"splash/style.css": "1b753c0b0be981e88026f85765c92568",
"favicon.ico": "2ce33d3617aa61acd82143c568193d31",
"index.html": "88f9f56a96f4436acb33a7abee5d8ff3",
"/": "88f9f56a96f4436acb33a7abee5d8ff3",
"CNAME": "aa71334148b7a6507b3fb188eeb6d867",
"main.dart.js": "72a233282cf6f78d72f0e1edc142c093",
"icons/favicon-16x16.png": "aac8f2524284b820acc81c95baa5e324",
"icons/favicon.ico": "c155661945bdc94d9a765d77031370b8",
"icons/apple-icon.png": "93b71a92aab0a3272bb03d4a1ade94d6",
"icons/apple-icon-144x144.png": "6ff471202353e83eda156cc483deeb7f",
"icons/android-icon-192x192.png": "3680402324ef1a1cd342da3816a9e2eb",
"icons/apple-icon-precomposed.png": "93b71a92aab0a3272bb03d4a1ade94d6",
"icons/apple-icon-114x114.png": "3e18f04a6ff26a970e560c8548d5ab55",
"icons/ms-icon-310x310.png": "32277eaaf61bac71acf894e6bc75731c",
"icons/ms-icon-144x144.png": "6ff471202353e83eda156cc483deeb7f",
"icons/apple-icon-57x57.png": "2ef29027c3a1642329466c0e991d0789",
"icons/apple-icon-152x152.png": "eb08d5132a940c87a45ab2c441b6d4a0",
"icons/ms-icon-150x150.png": "0a9c14696bbc1eb52750e7f87f53d281",
"icons/android-icon-72x72.png": "0b38a2dd043081dd0632e7dce5cf7f3d",
"icons/android-icon-96x96.png": "d02716ebcde20b87570bc35f9701697b",
"icons/android-icon-36x36.png": "e8e46c0739dfb98cdbbbeffc26d5b907",
"icons/apple-icon-180x180.png": "eb8ab8476950cac8abb9a5e0ebbf57e0",
"icons/favicon-96x96.png": "d02716ebcde20b87570bc35f9701697b",
"icons/manifest.json": "b58fcfa7628c9205cb11a1b2c3e8f99a",
"icons/android-icon-48x48.png": "c5d2024baec3748c8c59d5a98f715224",
"icons/apple-icon-76x76.png": "7d51d9daf4e100c10e61ad657418373e",
"icons/apple-icon-60x60.png": "81a39f0db32ff7a89dcfeb86820d2097",
"icons/browserconfig.xml": "653d077300a12f09a69caeea7a8947f8",
"icons/android-icon-144x144.png": "6ff471202353e83eda156cc483deeb7f",
"icons/apple-icon-72x72.png": "0b38a2dd043081dd0632e7dce5cf7f3d",
"icons/apple-icon-120x120.png": "650f16d4a10be62d7d850446d52148a5",
"icons/favicon-32x32.png": "2774a73e46630bc325e8edfd27aa16da",
"icons/ms-icon-70x70.png": "c68b13343f8c43478c0f247d0d6e87fe",
"manifest.json": "3ae217696040712908e772566eac365e",
"assets/AssetManifest.json": "a6797c0742356b267085f66a9215c753",
"assets/NOTICES": "b10679d31275ed2e9c9c748c4fcdbffd",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/packages/fluttertoast/assets/toastify.js": "e7006a0a033d834ef9414d48db3be6fc",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/fonts/MaterialIcons-Regular.otf": "4e6447691c9509f7acdbf8a931a85ca1",
"assets/assets/Icon256x256@2x.png": "180e7a963a983856d9f34c8872057b3d",
"assets/assets/HeaderImage.jpg": "eae1e45ed0d7b12fef7c44f5aecc2d18",
"assets/assets/HeaderImageLight.jpg": "126deaf4c727ea02ce32604c0d21a525",
"assets/assets/folder_preview.png": "899490d45ac49e28f6d31c410ca21171"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
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
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
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
