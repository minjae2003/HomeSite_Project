/*
 * 글쓰기/수정 화면 공통 에디터 (Summernote)
 * 사용: <textarea id="editor" name="content" data-upload-url="..." data-csrf="..."></textarea>
 *      + <input type="hidden" name="contentFormat" value="html">
 * 사진은 툴바/드래그/붙여넣기로 넣는 즉시 서버에 올라가고, 사진을 클릭하면 크기(25/50/100%)·정렬(왼쪽/오른쪽)을 바꿀 수 있다.
 */
(function ($) {
    var MAX_SIZE = 10 * 1024 * 1024;

    // dropRange가 있으면 그 위치에 직접 넣고, 없으면 현재 커서 위치에 넣음
    function uploadImage($editor, file, dropRange) {
        var url = $editor.data('upload-url');
        var csrf = $editor.data('csrf');
        if (file.size > MAX_SIZE) {
            alert('사진은 10MB까지 올릴 수 있습니다.');
            return;
        }
        var form = new FormData();
        form.append('image', file);
        fetch(url, {
            method: 'POST',
            headers: { 'X-CSRF-Token': csrf },
            body: form,
            credentials: 'same-origin'
        }).then(function (res) {
            if (res.status === 413) return { ok: false, message: '사진 용량이 너무 큽니다. (서버 업로드 용량 제한)' };
            return res.json().catch(function () { return { ok: false, message: '업로드에 실패했습니다. (' + res.status + ')' }; });
        }).then(function (data) {
            if (data && data.ok && dropRange) {
                var img = document.createElement('img');
                img.src = data.url;
                img.alt = file.name;
                img.style.maxWidth = '100%';
                dropRange.insertNode(img);
                $editor.next('.note-editor').find('.note-editable').trigger('input');
            } else if (data && data.ok) {
                $editor.summernote('insertImage', data.url, function ($img) {
                    $img.css('max-width', '100%');
                    $img.attr('alt', file.name);
                });
            } else {
                alert((data && data.message) || '사진 업로드에 실패했습니다.');
            }
        }).catch(function () {
            alert('사진 업로드 중 네트워크 오류가 발생했습니다.');
        });
    }

    $(function () {
        var $editor = $('#editor');
        if (!$editor.length) return;

        var mobile = window.matchMedia('(max-width: 768px)').matches;
        $editor.summernote({
            lang: 'ko-KR',
            height: mobile ? 300 : 420,
            placeholder: $editor.attr('placeholder') || '내용을 입력해 주세요.',
            // Summernote 기본 드롭 처리는 본문 안에서 사진을 끌어 옮길 때도 '새로 붙여넣기'로 처리해 사진이 복사됨
            // → 기본 처리는 끄고 아래에서 직접 처리 (사진 이동은 직접 구현, 밖에서 끌어온 파일만 업로드)
            disableDragAndDrop: true,
            toolbar: [
                ['style', ['style']],
                ['font', ['bold', 'italic', 'underline', 'strikethrough', 'clear']],
                ['fontsize', ['fontsize']],
                ['color', ['color']],
                ['para', ['ul', 'ol', 'paragraph']],
                ['insert', ['picture', 'link', 'table', 'hr']],
                ['misc', ['undo', 'redo']]
            ],
            popover: {
                image: [
                    ['resize', ['resizeFull', 'resizeHalf', 'resizeQuarter', 'resizeNone']],
                    ['float', ['floatLeft', 'floatRight', 'floatNone']],
                    ['remove', ['removeMedia']]
                ],
                link: [['link', ['linkDialogShow', 'unlink']]],
                table: [
                    ['add', ['addRowDown', 'addRowUp', 'addColLeft', 'addColRight']],
                    ['delete', ['deleteRow', 'deleteCol', 'deleteTable']]
                ]
            },
            callbacks: {
                onImageUpload: function (files) {
                    for (var i = 0; i < files.length; i++) uploadImage($editor, files[i]);
                },
                // 다른 사이트에서 복사한 내용은 서식 없이 글자만 붙여넣기 (외부 이미지/스크립트 차단)
                onPaste: function (e) {
                    var cb = (e.originalEvent || e).clipboardData;
                    if (!cb) return;
                    if (cb.files && cb.files.length) return;   // 사진 붙여넣기는 onImageUpload가 처리
                    var html = cb.getData('text/html');
                    if (html) {
                        e.preventDefault();
                        document.execCommand('insertText', false, cb.getData('text/plain'));
                    }
                }
            }
        });

        var $editable = $editor.next('.note-editor').find('.note-editable');
        var $handle = $editor.next('.note-editor').find('.note-control-selection');

        function rangeAt(x, y) {
            if (document.caretRangeFromPoint) return document.caretRangeFromPoint(x, y);
            if (document.caretPositionFromPoint) {           // Firefox
                var pos = document.caretPositionFromPoint(x, y);
                if (!pos) return null;
                var r = document.createRange();
                r.setStart(pos.offsetNode, pos.offset);
                r.collapse(true);
                return r;
            }
            return null;
        }

        // 브라우저 기본 이미지 드래그는 막음 (기본 동작이 '복사 붙여넣기'로 처리돼 사진이 2장이 되는 원인)
        $editable.on('dragstart', function (e) {
            if (e.target.tagName === 'IMG') e.preventDefault();
        });

        // 사진 옮기기: 사진(또는 선택 테두리)을 누른 채 끌어서 원하는 위치에 놓으면 그 자리로 '이동'
        var moving = null, moved = false, startX = 0, startY = 0, $ghost = null;
        function beginMove(img, e) {
            if (e.button !== 0 || !img) return;
            moving = img; moved = false; startX = e.clientX; startY = e.clientY;
        }
        $editable.on('mousedown', 'img', function (e) { beginMove(this, e); });
        $handle.find('.note-control-selection-bg').on('mousedown', function (e) {
            var $t = $handle.data('target');
            beginMove($t && $t[0], e);
        });
        $(document).on('mousemove', function (e) {
            if (!moving) return;
            if (!moved) {
                if (Math.abs(e.clientX - startX) + Math.abs(e.clientY - startY) < 6) return;
                moved = true;
                $handle.hide();
                $('.note-image-popover').hide();
                $ghost = $(moving).clone().removeAttr('style').css({
                    position: 'fixed', width: Math.min(160, moving.width) + 'px', height: 'auto', opacity: 0.6,
                    pointerEvents: 'none', zIndex: 10000, borderRadius: '6px', boxShadow: '0 4px 14px rgba(0,0,0,.25)'
                }).appendTo(document.body);
                $(moving).css('opacity', 0.3);
                $('body').css('cursor', 'grabbing');
            }
            $ghost.css({ left: e.clientX + 12 + 'px', top: e.clientY + 12 + 'px' });
            e.preventDefault();
        });
        $(document).on('mouseup', function (e) {
            if (!moving) return;
            var img = moving;
            var oldParent = img.parentNode;
            moving = null;
            if (!moved) return;                      // 그냥 클릭이면 Summernote가 크기/정렬 메뉴를 보여줌
            $ghost.remove(); $ghost = null;
            $(img).css('opacity', '');
            $('body').css('cursor', '');
            var range = rangeAt(e.clientX, e.clientY);
            if (range && $editable[0].contains(range.startContainer) && !img.contains(range.startContainer)) {
                range.insertNode(img);
                // 사진이 빠져나가 빈 문단이 남으면 정리
                if (oldParent && oldParent !== $editable[0] && !oldParent.contains(img)
                        && !oldParent.textContent.trim() && !oldParent.querySelector('img')) {
                    $(oldParent).remove();
                }
                var sel = window.getSelection();
                sel.removeAllRanges();
                range.setStartAfter(img); range.collapse(true);
                sel.addRange(range);
                $editable.trigger('input');
            }
        });

        // 밖(내 PC)에서 사진 파일을 끌어다 놓으면 놓은 자리에 업로드해서 넣기
        $editable.on('drop', function (e) {
            var dt = e.originalEvent.dataTransfer;
            if (dt && dt.files && dt.files.length) {
                e.preventDefault();
                var range = rangeAt(e.originalEvent.clientX, e.originalEvent.clientY);
                if (range && !$editable[0].contains(range.startContainer)) range = null;
                for (var i = 0; i < dt.files.length; i++) {
                    if (/^image\//.test(dt.files[i].type)) uploadImage($editor, dt.files[i], range ? range.cloneRange() : null);
                    else alert('본문에는 사진만 끌어다 넣을 수 있어요. 동영상/문서는 아래 첨부란을 이용해 주세요.');
                }
            }
        });
        // 편집창 밖에 파일을 떨어뜨려도 브라우저가 그 파일로 이동하지 않도록
        $(document).on('dragover drop', function (e) {
            if (!$(e.target).closest('.note-editable, input[type=file]').length) e.preventDefault();
        });

        $editor.closest('form').on('submit', function () {
            var code = $editor.summernote('code');
            var hasText = $('<div>').html(code).text().trim().length > 0;
            var hasImg = /<img\s/i.test(code);
            if ($editor.summernote('isEmpty') && !hasImg || (!hasText && !hasImg)) {
                alert('내용을 입력해 주세요.');
                $editor.summernote('focus');
                return false;
            }
            $editor.val(code);
            return true;
        });
    });
})(jQuery);
