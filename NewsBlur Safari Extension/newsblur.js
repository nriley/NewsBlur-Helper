// Don't load in iframes
if (window.top === window) {

    // Don't examine content until it's available
    document.addEventListener("DOMContentLoaded", function(e) {

        if (!document.body.classList.contains('NB-body-main') && !document.body.classList.contains('NB-welcome')) {
            return; // Don't even launch the app extension to ask for newsBlurDomain unless we're in NewsBlur
        }

        var newsBlurDomain = undefined;

        safari.self.addEventListener('message', function(e) {
            if (e.name != 'updateSettings')
                return;

            console.log('updating newsBlurDomain: ' + e.message.newsBlurDomain + ' - was: ' + newsBlurDomain);
            newsBlurDomain = e.message.newsBlurDomain;
        });
        safari.extension.dispatchMessage('getSettings');

        window.addEventListener('openInNewTab', function(e) {
            // Only work from NewsBlur domain
            var documentDomain = e.srcElement.ownerDocument.domain.toLowerCase();
            if (documentDomain != newsBlurDomain && !documentDomain.endsWith('.' + newsBlurDomain))
                return;

            // Tell NewsBlur that we opened the story via the DOM
            // (since we can't do it by manipulating the event any more)
            e.target.parentElement.classList.add('NB-story-webkit-opened');

            var message = {
                href: e.target.href,
                background: e.detail.background
            };

            safari.extension.dispatchMessage('openInNewTab', message);
        });
    });
}
