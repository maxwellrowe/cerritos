(function () {
  function decodeLikeXsl(s) {
    const map = {
      '9':'a','8':'b','7':'c','6':'d','5':'e','4':'f','3':'g','2':'h','1':'i','0':'j',
      '!':'k','`':'l','~':'m','$':'n',':':'o','^':'p','*':'q','(':'r',')':'s','[':'t',
      ']':'u','|':'v','/':'w','\\':'x','-':'y','_':'z',
      'a':'(','b':')','c':'.','d':' ','e':'-','f':"'"
    };

    return (s || '')
      .split('')
      .map(ch => Object.prototype.hasOwnProperty.call(map, ch) ? map[ch] : ch)
      .join('');
  }

  function buildEmail(el) {
    const user = decodeLikeXsl(el.getAttribute('data-u') || '');
    const d1 = decodeLikeXsl(el.getAttribute('data-d1') || '');
    const d2 = decodeLikeXsl(el.getAttribute('data-d2') || '');

    if (!user || !d1 || !d2) return '';

    return user + '@' + d1 + '.' + d2;
  }

  async function copyText(text) {
    if (!text) return false;

    try {
      if (navigator.clipboard && window.isSecureContext) {
        await navigator.clipboard.writeText(text);
        return true;
      }
    } catch (err) {}

    try {
      const input = document.createElement('input');
      input.type = 'text';
      input.value = text;
      input.setAttribute('readonly', '');
      input.style.position = 'absolute';
      input.style.left = '-9999px';
      document.body.appendChild(input);
      input.select();
      input.setSelectionRange(0, input.value.length);
      const ok = document.execCommand('copy');
      document.body.removeChild(input);
      return ok;
    } catch (err) {
      return false;
    }
  }

  function showCopiedState(button, success) {
    if (!button) return;

    const originalTitle = button.getAttribute('aria-label') || 'Copy email address';
    const newLabel = success ? 'Email address copied' : 'Unable to copy email address';

    button.setAttribute('aria-label', newLabel);
    button.classList.add(success ? 'is-copied' : 'is-copy-failed');

    window.setTimeout(function () {
      button.setAttribute('aria-label', originalTitle);
      button.classList.remove('is-copied', 'is-copy-failed');
    }, 1500);
  }

  document.addEventListener('click', async function (event) {
    const emailLink = event.target.closest('.email-secure-link');
    if (emailLink) {
      event.preventDefault();
      const email = buildEmail(emailLink);
      if (email) {
        window.location.href = 'mailto:' + email;
      }
      return;
    }

    const copyButton = event.target.closest('.email-secure-copy');
    if (copyButton) {
      event.preventDefault();
      const email = buildEmail(copyButton);
      const ok = await copyText(email);
      showCopiedState(copyButton, ok);
    }
  });
})();