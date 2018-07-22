var newsBlurDomain = undefined;

safari.self.addEventListener('message', function(e) {
    if (e.name != 'updateSettings')
        return;

    newsBlurDomain = e.message.newsBlurDomain;
    console.log('updated newsBlurDomain: ' + newsBlurDomain);
});
safari.extension.dispatchMessage('getSettings');

window.addEventListener('openInNewTab', function(e) {
    // Only work from NewsBlur domain
    var documentDomain = e.srcElement.ownerDocument.domain.toLowerCase();
    if (documentDomain != newsBlurDomain && !documentDomain.endsWith('.' + newsBlurDomain))
        return;

    var message = {
        href: e.target.href,
        background: e.detail.background
    };

    safari.extension.dispatchMessage('openInNewTab', message);
});