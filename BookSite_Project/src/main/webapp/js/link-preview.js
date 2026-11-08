(function () {
    var MAX_CARDS = 5;

    function domainOf(url) {
        try { return new URL(url).hostname.replace(/^www\./, ''); } catch (e) { return ''; }
    }

    function makeCard(data) {
        var a = document.createElement('a');
        a.className = 'lp-card';
        a.href = data.url;
        a.target = '_blank';
        a.rel = 'noopener noreferrer nofollow';

        if (data.image) {
            var box = document.createElement('div');
            box.className = 'lp-thumb';
            var img = document.createElement('img');
            img.src = data.image;
            img.alt = '';
            img.loading = 'lazy';
            img.referrerPolicy = 'no-referrer';
            img.onerror = function () { box.remove(); a.classList.add('no-image'); };
            box.appendChild(img);
            if (data.video) {
                var play = document.createElement('span');
                play.className = 'lp-play';
                play.setAttribute('aria-hidden', 'true');
                box.appendChild(play);
                a.classList.add('video');
            }
            a.appendChild(box);
        } else {
            a.classList.add('no-image');
        }

        var body = document.createElement('div');
        body.className = 'lp-body';
        var title = document.createElement('div');
        title.className = 'lp-title';
        title.textContent = data.title || domainOf(data.url);
        body.appendChild(title);
        if (data.desc) {
            var desc = document.createElement('div');
            desc.className = 'lp-desc';
            desc.textContent = data.desc;
            body.appendChild(desc);
        }
        var site = document.createElement('div');
        site.className = 'lp-site';
        site.textContent = domainOf(data.url) || data.site;
        body.appendChild(site);
        a.appendChild(body);
        return a;
    }

    function isBareLink(a) {
        var href = a.getAttribute('href') || '';
        var text = (a.textContent || '').trim();
        if (!/^https?:\/\//i.test(href) || a.querySelector('img')) return false;
        return text === href || 'http://' + text === href || 'https://' + text === href;
    }

    function start() {
        var box = document.getElementById('linkPreviews');
        var content = document.querySelector('.post-content');
        if (!box || !content) return;
        var num = box.getAttribute('data-num');
        var endpoint = box.getAttribute('data-endpoint');

        var links = content.querySelectorAll('a[href]');
        var count = 0;
        for (var i = 0; i < links.length && count < MAX_CARDS; i++) {
            if (!isBareLink(links[i])) continue;
            count++;
            (function (a) {
                var url = a.getAttribute('href');
                fetch(endpoint + '?num=' + encodeURIComponent(num) + '&url=' + encodeURIComponent(url), { credentials: 'same-origin' })
                    .then(function (res) { return res.ok ? res.json() : null; })
                    .then(function (data) {
                        if (!data || !data.ok) return;
                        var card = makeCard(data);
                        card.classList.add('inline');
                        a.parentNode.replaceChild(card, a);
                        var next = card.nextSibling;
                        if (next && next.nodeName === 'BR') next.remove();
                        else if (next && next.nodeType === 3) next.nodeValue = next.nodeValue.replace(/^\r?\n/, '');
                    })
                    .catch(function () {});
            })(links[i]);
        }
    }

    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start);
    else start();
})();
