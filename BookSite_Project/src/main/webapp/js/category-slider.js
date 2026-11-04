/**
 * 카테고리 탭 슬라이더 (모바일용)
 *  - 좌우 화살표 버튼으로 탭 넘기기
 *  - 손가락 스와이프 / 마우스 드래그로 넘기기 (드래그 후에는 링크가 눌리지 않도록 처리)
 *  - 선택된 탭을 처음부터 가운데에 보여 줌
 *  - 더 넘길 수 있는 방향에만 화살표와 흐림 효과 표시
 * 마크업: <div class="tab-slider"> <button class="tab-arrow prev"> <div class="category-tabs">…</div> <button class="tab-arrow next"> </div>
 */
(function () {
    document.querySelectorAll('.tab-slider').forEach(function (slider) {
        var track = slider.querySelector('.category-tabs');
        var prev = slider.querySelector('.tab-arrow.prev');
        var next = slider.querySelector('.tab-arrow.next');
        if (!track) return;

        function update() {
            var max = track.scrollWidth - track.clientWidth;
            var canPrev = track.scrollLeft > 16;   // 16px 이하로 남으면 끝에 도달한 것으로 봄
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

        // 마우스 드래그로 넘기기 (PC 개발자도구 모바일 모드에서도 동작하도록)
        var down = false, moved = false, startX = 0, startLeft = 0;
        track.addEventListener('pointerdown', function (e) {
            if (e.pointerType !== 'mouse') return;   // 터치는 브라우저 기본 스크롤 사용
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
        // 드래그한 직후의 클릭은 무시 (밀다가 탭이 눌려 이동하는 것 방지)
        track.addEventListener('click', function (e) {
            if (moved) { e.preventDefault(); e.stopPropagation(); moved = false; }
        }, true);
        track.addEventListener('dragstart', function (e) { e.preventDefault(); });

        update();
    });
})();
