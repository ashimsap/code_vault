document.addEventListener('DOMContentLoaded', () => {
    const mainView = document.getElementById('main-view');
    const detailView = document.getElementById('detail-view');
    const snippetsGrid = document.getElementById('snippets-grid');
    const fab = document.getElementById('fab');

    let snippets = [];
    let currentSnippet = null;
    let saveDebounceTimer;
    let keepAliveTimer;

    const main = async () => {
        try {
            const status = await checkStatus();
            applyTheme(status);
            startKeepAlive();
            await fetchData();
            handleRouting();
        } catch (error) {
            document.body.innerHTML = `<div class="permission-denied"><h1>Paila Dai Lai Sodh</h1><p>(Ask permission from the Host.)</p></div>`;
        }
    };

    const checkStatus = async () => {
        const response = await fetch('/status');
        if (!response.ok) throw new Error('Permission Denied');
        return response.json();
    };

    const startKeepAlive = () => {
        keepAliveTimer = setInterval(checkStatus, 15000);
    };

    const handleRouting = async () => {
        const hash = window.location.hash;
        if (hash.startsWith('#snippet/')) {
            const id = hash.substring(9);
            if (id === 'new') {
                await openDetailView(null);
            } else {
                const snippet = snippets.find(s => s.id === parseInt(id));
                if (snippet) {
                    await openDetailView(snippet);
                } else {
                    showMainView();
                }
            }
        } else {
            showMainView();
        }
    };

    const fetchData = async () => {
        try {
            const snippetsRes = await fetch('/api/snippets');
            if (!snippetsRes.ok) throw new Error('Failed to fetch snippets');
            snippets = await snippetsRes.json();
            renderSnippetsGrid();
        } catch (error) {
            console.error('Error fetching data:', error);
        }
    };

    const renderSnippetsGrid = () => {
        snippetsGrid.innerHTML = snippets.map(snippet => {
            let bodyContent = '';
            
            if (snippet.firstMediaUrl) {
                bodyContent = `<div class="card-media"><img src="${snippet.firstMediaUrl}" alt="Media"></div>`;
            } else {
                // If no media, only show description
                const descriptionHtml = snippet.fullDescription 
                    ? `<div class="card-description">${escapeHtml(snippet.fullDescription)}</div>` 
                    : '';
                // Code is intentionally hidden in the card preview
                bodyContent = `<div class="card-text-body">${descriptionHtml}</div>`;
            }
            
            return `
                <div class="snippet-card" data-id="${snippet.id}">
                    <div class="card-header">
                        <div class="card-title">${escapeHtml(snippet.description)}</div>
                    </div>
                    ${bodyContent}
                </div>
            `;
        }).join('');
    };

    const createNewSnippet = async () => {
        const newSnippetData = {
            description: '', // Initial value is empty for auto-delete check
            fullDescription: '',
            codeContent: '',
            mediaPaths: [],
            creationDate: new Date().toISOString(),
            lastModificationDate: new Date().toISOString(),
            categories: '',
            deviceSource: 'Web Client'
        };
        try {
            const response = await fetch('/api/snippets/create', { 
                method: 'POST', 
                headers: { 'Content-Type': 'application/json' }, 
                body: JSON.stringify(newSnippetData) 
            });
            if (!response.ok) throw new Error('Create failed!');
            return await response.json();
        } catch (error) {
            console.error('Error creating new snippet:', error);
            return null;
        }
    };

    const openDetailView = async (snippet) => {
        if (!snippet) {
            snippet = await createNewSnippet();
            if (!snippet) {
                alert('Failed to create new snippet');
                showMainView();
                return;
            }
            history.replaceState(null, '', `#snippet/${snippet.id}`);
            await fetchData();
        }

        currentSnippet = snippet;
        
        const mediaContent = currentSnippet.firstMediaUrl 
            ? `<img src="${currentSnippet.firstMediaUrl}" alt="Snippet Media">`
            : 'Click to Add Media';

        detailView.innerHTML = `
            <div class="detail-header"><button class="back-button">&larr;</button></div>
            <div class="detail-body">
                <div class="detail-top-section">
                    <div class="detail-meta-content">
                        <input type="text" id="detail-title" value="${escapeHtml(currentSnippet.description)}" placeholder="Title...">
                        <textarea id="detail-description" placeholder="Description...">${escapeHtml(currentSnippet.fullDescription || '')}</textarea>
                    </div>
                    <div class="detail-media-box">
                        <label id="media-upload-label" for="media-upload">${mediaContent}</label>
                        <input type="file" id="media-upload" style="display:none;" accept="image/*">
                    </div>
                </div>
                <div class="code-editor-wrapper">
                    <div id="line-numbers" class="line-numbers">1</div>
                    <textarea id="detail-code" class="code-editor" placeholder="Code..." spellcheck="false">${escapeHtml(currentSnippet.codeContent || '')}</textarea>
                </div>
            </div>
        `;
        mainView.style.display = 'none';
        detailView.style.display = 'flex';

        const codeEditor = document.getElementById('detail-code');
        const lineNumbers = document.getElementById('line-numbers');
        
        const syncScroll = () => { lineNumbers.scrollTop = codeEditor.scrollTop; };
        const updateLineNumbers = () => {
            const lines = codeEditor.value.split('\n').length || 1;
            lineNumbers.innerHTML = Array.from({length: lines}, (_, i) => i + 1).join('\n');
            syncScroll();
        };
        
        codeEditor.addEventListener('input', updateLineNumbers);
        codeEditor.addEventListener('scroll', syncScroll);
        updateLineNumbers();

        document.querySelector('.back-button').addEventListener('click', () => window.history.back());
        ['detail-title', 'detail-description', 'detail-code'].forEach(id => {
            document.getElementById(id).addEventListener('input', handleAutoSave);
        });
        document.getElementById('media-upload').addEventListener('change', uploadMedia);
    };

    const showMainView = async () => {
        // Auto-delete empty snippets on backing out
        if (currentSnippet && currentSnippet.id) {
            // First, ensure the final state is captured from the UI
            const finalDescription = document.getElementById('detail-title').value;
            const finalFullDescription = document.getElementById('detail-description').value;
            const finalCodeContent = document.getElementById('detail-code').value;

            // Updated check: consider empty if description/title is empty, even if media exists?
            // User requirement: "auto delete the snippet if the contents are blank like no title nodescription no media and no code"
            const isUnedited = 
                !finalDescription && 
                !finalFullDescription && 
                !finalCodeContent && 
                (!currentSnippet.mediaPaths || currentSnippet.mediaPaths.length === 0);

            if (isUnedited) {
                await fetch(`/api/snippets/delete?id=${currentSnippet.id}`, { method: 'POST' });
            } else {
                await saveSnippet(); // Save any last minute changes
            }
        }

        currentSnippet = null;
        detailView.style.display = 'none';
        mainView.style.display = 'block';
        if (window.location.hash) window.history.pushState("", document.title, window.location.pathname + window.location.search);
        fetchData();
    };

    const handleAutoSave = () => {
        clearTimeout(saveDebounceTimer);
        saveDebounceTimer = setTimeout(saveSnippet, 1500);
    };

    const saveSnippet = async () => {
        if (!currentSnippet) return;
        const endpoint = '/api/snippets/update';
        
        let snippetData = {
            ...currentSnippet,
            description: document.getElementById('detail-title').value,
            fullDescription: document.getElementById('detail-description').value,
            codeContent: document.getElementById('detail-code').value,
            lastModificationDate: new Date().toISOString(),
            categories: (currentSnippet.categories || []).join(','),
        };

        try {
            const response = await fetch(endpoint, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(snippetData) });
            if (!response.ok) throw new Error('Save failed!');
        } catch (error) {
            console.error('Error saving snippet:', error);
        }
    };

    const uploadMedia = async (event) => {
        const file = event.target.files[0];
        if (!file || !currentSnippet.id) {
            alert("Error: Snippet not saved on server yet. Please wait or try again.");
            return;
        }

        const formData = new FormData();
        formData.append('media', file);

        try {
            const response = await fetch(`/api/media/upload?snippetId=${currentSnippet.id}`, { method: 'POST', body: formData });
            if (!response.ok) throw new Error('Upload failed!');
            const updatedSnippet = await response.json();
            currentSnippet = updatedSnippet;
            const mediaContent = currentSnippet.firstMediaUrl 
                ? `<img src="${currentSnippet.firstMediaUrl}" alt="Snippet Media">`
                : 'Click to Add Media';
            document.getElementById('media-upload-label').innerHTML = mediaContent;
            
        } catch(error) {
            console.error('Error uploading media:', error);
            alert("Media upload failed.");
        }
    };

    const applyTheme = (theme) => {
        document.documentElement.style.setProperty('--accent-color', theme.accentColor);
        // Set RGB for RGBA fallback
        const hex = theme.accentColor.replace('#', '');
        const r = parseInt(hex.substring(0, 2), 16);
        const g = parseInt(hex.substring(2, 4), 16);
        const b = parseInt(hex.substring(4, 6), 16);
        document.documentElement.style.setProperty('--accent-color-rgb', `${r}, ${g}, ${b}`);

        document.body.classList.toggle('dark-mode', theme.themeMode === 'dark');
    };

    const escapeHtml = (unsafe) => unsafe ? unsafe.replace(/[&<"']/g, m => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[m])) : '';

    snippetsGrid.addEventListener('click', (e) => {
        const card = e.target.closest('.snippet-card');
        if (card) window.location.hash = `#snippet/${card.dataset.id}`;
    });
    
    window.addEventListener('popstate', handleRouting);

    fab.addEventListener('click', () => window.location.hash = '#snippet/new');

    main();
});
