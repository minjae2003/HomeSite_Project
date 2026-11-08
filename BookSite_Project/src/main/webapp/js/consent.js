(function () {
    function boxes(form) {
        return form ? form.querySelectorAll('[data-consent]') : document.querySelectorAll('[data-consent]');
    }
    function init(box) {
        var all = box.querySelector('.consent-all-check');
        var reqs = box.querySelectorAll('.consent-req');
        function sync() {
            var on = true;
            for (var i = 0; i < reqs.length; i++) if (!reqs[i].checked) on = false;
            all.checked = on;
            if (on) box.classList.remove('consent-error');
        }
        all.addEventListener('change', function () {
            for (var i = 0; i < reqs.length; i++) reqs[i].checked = all.checked;
            sync();
        });
        for (var i = 0; i < reqs.length; i++) reqs[i].addEventListener('change', sync);

        var toggles = box.querySelectorAll('.consent-toggle');
        for (var j = 0; j < toggles.length; j++) {
            toggles[j].addEventListener('click', function () {
                var detail = this.parentNode.querySelector('.consent-detail');
                var open = detail.hasAttribute('hidden');
                if (open) detail.removeAttribute('hidden'); else detail.setAttribute('hidden', '');
                this.setAttribute('aria-expanded', open ? 'true' : 'false');
                this.textContent = open ? '내용 접기 ▴' : '내용 보기 ▾';
            });
        }
    }

    window.consentCheck = function (form) {
        var list = boxes(form);
        for (var b = 0; b < list.length; b++) {
            var reqs = list[b].querySelectorAll('.consent-req');
            for (var i = 0; i < reqs.length; i++) {
                if (!reqs[i].checked) {
                    list[b].classList.add('consent-error');
                    alert('필수 항목에 모두 동의해 주세요.');
                    reqs[i].focus();
                    list[b].scrollIntoView({ behavior: 'smooth', block: 'center' });
                    return false;
                }
            }
        }
        return true;
    };
    window.consentReset = function (form) {
        var list = boxes(form);
        for (var b = 0; b < list.length; b++) {
            var inputs = list[b].querySelectorAll('input[type=checkbox]');
            for (var i = 0; i < inputs.length; i++) inputs[i].checked = false;
            list[b].classList.remove('consent-error');
        }
    };

    function start() {
        var list = boxes();
        for (var i = 0; i < list.length; i++) init(list[i]);
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start);
    else start();
})();
