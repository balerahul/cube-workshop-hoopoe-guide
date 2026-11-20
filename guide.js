(() => {
  'use strict';
  // Job choices: the buttons in step 4 switch every [data-job] block and file name on the page.
  const jobs = {
    cpu:      {label: 'the CPU job (LocalQ, 4 ranks)', file: 'cpu.sbatch', prefix: 'cpu', short: 'CPU'},
    a100:     {label: 'the one-A100 job (gpu partition)', file: 'a100.sbatch', prefix: 'a100', short: '1 × A100'},
    h100:     {label: 'the one-H100 job (hgpuq partition)', file: 'h100.sbatch', prefix: 'h100', short: '1 × H100'},
    multigpu: {label: 'the two-H100 job (hgpuq, 2 ranks)', file: 'multigpu.sbatch', prefix: 'multigpu', short: '2 × H100'}
  };
  const all = (sel) => document.querySelectorAll(sel);
  const status = (text) => { const el = document.getElementById('copy-status'); if (el) el.textContent = text; };

  function selectJob(key) {
    const job = jobs[key];
    if (!job) return;
    all('[data-job]').forEach(el => { el.hidden = !el.dataset.job.split(' ').includes(key); });
    all('[data-choose-job]').forEach(el => el.setAttribute('aria-pressed', String(el.dataset.chooseJob === key)));
    all('[data-job-file]').forEach(el => { el.textContent = job.file; });
    all('[data-job-prefix]').forEach(el => { el.textContent = job.prefix; });
    all('[data-job-link]').forEach(el => { el.href = 'jobs/' + job.file; });
    all('[data-job-short]').forEach(el => { el.textContent = job.short; });
    const s = document.getElementById('job-status');
    if (s) s.textContent = 'Showing ' + job.label + '.';
    try { localStorage.setItem('hoopoe-guide-job', key); } catch (e) { /* storage may be blocked */ }
  }

  all('[data-choose-job]').forEach(b => b.addEventListener('click', () => selectJob(b.dataset.chooseJob)));
  let initial = 'cpu';
  try { const stored = localStorage.getItem('hoopoe-guide-job'); if (jobs[stored]) initial = stored; } catch (e) { /* ignore */ }
  selectJob(initial);

  // Job ID box (step 6): fills the student's own job ID into every command on the page.
  const idInput = document.getElementById('jobid-input');
  function setJobId(value) {
    const id = /^\d{1,9}$/.test(value) ? value : '';
    all('[data-jobid]').forEach(el => { el.textContent = id || '12345'; el.classList.toggle('filled', !!id); });
    try { if (id) localStorage.setItem('hoopoe-guide-jobid', id); else localStorage.removeItem('hoopoe-guide-jobid'); } catch (e) { /* ignore */ }
  }
  if (idInput) {
    idInput.addEventListener('input', () => { idInput.value = idInput.value.replace(/\D/g, ''); setJobId(idInput.value); });
    try { const saved = localStorage.getItem('hoopoe-guide-jobid'); if (saved) { idInput.value = saved; setJobId(saved); } } catch (e) { /* ignore */ }
  }

  // Phone step menu: close it after a step is chosen.
  const mobileSteps = document.querySelector('.mobile-steps');
  if (mobileSteps) mobileSteps.querySelectorAll('a').forEach(a => a.addEventListener('click', () => { mobileSteps.open = false; }));

  // Copy buttons: clipboard first, text selection as the fallback (file:// pages may block the clipboard).
  all('.copy-command').forEach(button => button.addEventListener('click', async () => {
    const box = button.closest('.command');
    const code = box && box.querySelector('code');
    if (!code) return;
    try {
      await navigator.clipboard.writeText(code.textContent);
      button.textContent = 'Copied';
      const old = box.querySelector('.copy-help'); if (old) old.remove();
      status('Command copied. Paste it into your terminal and press Enter.');
    } catch (e) {
      const range = document.createRange(); range.selectNodeContents(code);
      const sel = window.getSelection(); sel.removeAllRanges(); sel.addRange(range);
      let help = box.querySelector('.copy-help');
      if (!help) { help = document.createElement('p'); help.className = 'copy-help'; help.setAttribute('role', 'status'); box.appendChild(help); }
      const keys = /Mac/i.test(navigator.platform || navigator.userAgent) ? 'Command + C' : 'Ctrl + C';
      help.textContent = 'The command is selected. Press ' + keys + ' to copy it, then paste it into your terminal.';
      button.textContent = 'Selected';
      status('The command is selected. Press ' + keys + ' to copy it.');
    }
    setTimeout(() => { button.textContent = 'Copy'; }, 1800);
  }));

  const printButton = document.getElementById('print-guide');
  if (printButton) printButton.addEventListener('click', () => window.print());
  const notice = document.getElementById('preview-notice');
  if (notice) notice.hidden = !['localhost', '127.0.0.1', ''].includes(location.hostname);

  // Highlight the current section in the sidebar.
  if ('IntersectionObserver' in window) {
    const links = all('.step-nav nav a');
    const observer = new IntersectionObserver(entries => {
      for (const entry of entries) if (entry.isIntersecting) {
        links.forEach(a => a.classList.toggle('active', a.hash === '#' + entry.target.id));
      }
    }, {rootMargin: '-110px 0px -65% 0px'});
    all('main>section[id]').forEach(section => observer.observe(section));
  }
})();
