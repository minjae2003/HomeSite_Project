(function () {
    document.querySelectorAll('.tab-slider').forEach(function (slider) {
        var track = slider.querySelector('.category-tabs');
        var prev = slider.querySelector('.tab-arrow.prev');
        var next = slider.querySelector('.tab-arrow.next');
        if (!track) return;

        function update() {
            var max = track.scrollWidth - track.clientWidth;
            var canPrev = track.scrollLeft > 16;
            var canNext = track.scrollLeft < max - 16;
            slider.classList.toggle('can-prev', canPrev);
            slider.classList.toggle('can-next', canNext);
            if (prev) prev.hidden = !canPrev;
            if (next) next.hidden = !canNext;
        }

        function step(dir) {
            track.scrollBy({ left: dir * track.clientWidth * 0.7, behavior: 'smooth' });
        }
        if (prev) prev.addEventListener('click', function () { step(-1); });
        if (next) next.addEventListener('click', function () { step(1); });

        track.addEventListener('scroll', update, { passive: true });
        window.addEventListener('resize', update);

        var active = track.querySelector('.tab-item.active');
        if (active) {
            track.scrollLeft = active.offsetLeft - (track.clientWidth - active.offsetWidth) / 2;
        }

        var down = false, moved = false, startX = 0, startLeft = 0;
        track.addEventListener('pointerdown', function (e) {
            if (e.pointerType !== 'mouse') return;
            down = true; moved = false; startX = e.clientX; startLeft = track.scrollLeft;
        });
        window.addEventListener('pointermove', function (e) {
            if (!down) return;
            var dx = e.clientX - startX;
            if (Math.abs(dx) > 5) {
                moved = true;
                track.style.scrollSnapType = 'none';
                track.style.scrollBehavior = 'auto';
                track.scrollLeft = startLeft - dx;
            }
        });
        window.addEventListener('pointerup', function () {
            if (!down) return;
            down = false;
            track.style.scrollSnapType = '';
            track.style.scrollBehavior = '';
        });
        track.addEventListener('click', function (e) {
            if (moved) { e.preventDefault(); e.stopPropagation(); moved = false; }
        }, true);
        track.addEventListener('dragstart', function (e) { e.preventDefault(); });

        update();
    });
})();
