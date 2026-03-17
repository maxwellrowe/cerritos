// Loader Functions
function showDirectoryLoader() {
  document.getElementById("directory-loader").hidden = false;
  document.getElementById("directory").setAttribute("hidden", "");
}
function hideDirectoryLoader() {
  document.getElementById("directory-loader").hidden = true;
  document.getElementById("directory").removeAttribute("hidden");
}

/* ===== Email encode/decode (mirrors your XSL mapping) ===== */
function encodeLikeXsl(s) {
  const map = {
    a:'9', b:'8', c:'7', d:'6', e:'5', f:'4', g:'3', h:'2', i:'1', j:'0',
    k:'!', l:'`', m:'~', n:'$', o:':', p:'^', q:'*', r:'(', s:')', t:'[',
    u:']', v:'|', w:'/', x:'\\', y:'-', z:'_', '(': 'a', ')':'b', '.':'c',
    ' ':'d', '-':'e', "'":'f'
  };
  return (s || "")
    .toLowerCase()
    .split("")
    .map(ch => map[ch] ?? ch) // leave '@' and other chars as-is
    .join("");
}
function decodeLikeXsl(s) {
  const map = {
    '9':'a','8':'b','7':'c','6':'d','5':'e','4':'f','3':'g','2':'h','1':'i','0':'j',
    '!':'k','`':'l','~':'m','$':'n',':':'o','^':'p','*':'q','(':'r',')':'s','[':'t',
    ']':'u','|':'v','/':'w','\\':'x','-':'y','_':'z', 'a':'(', 'b':')', 'c':'.',
    'd':' ', 'e':'-', 'f':"'"
  };
  return (s || "")
    .split("")
    .map(ch => map[ch] ?? ch)
    .join("");
}

// Function to load directory. "xml" var is required. "formtomailurl" and "divdept" are optional.
async function loadDirectory(options = {}) {
  showDirectoryLoader();
  try {
    // ----- Required options -----
    if (!options.xml || options.xml.trim() === "") {
      throw new Error("Missing required 'xml' option");
    }

    // ----- Build request URL -----
    let url = "/_resources/directory/directory-parser.php";
    const params = new URLSearchParams({ xml: options.xml.trim() });

    if (options.formtomailurl && options.formtomailurl.trim() !== "") {
      params.set("formtomailurl", options.formtomailurl.trim());
    }
    if (options.divdept && options.divdept.trim() !== "") {
      params.set("divdept", options.divdept.trim());
    }
    url += "?" + params.toString();

    // ----- Fetch -----
    const res = await fetch(url, { headers: { "Accept": "application/json" } });
    if (!res.ok) throw new Error("Request failed: " + res.status);

    const data = await res.json();
    if (!data.employees || !Array.isArray(data.employees)) {
      throw new Error("Unexpected JSON format");
    }

    // ---------- State ----------
    const employees = data.employees.slice(); // assume sorted
    let searchQuery = "";
    let selectedDepts = new Set(); // empty => All Departments

    // ---------- Build deptList (UNIQUE, sorted) ----------
    const deptMap = new Map(); // key: lowercased dept, value: display label
    for (const e of employees) {
      if (e.divdept && e.divdept.trim() !== "") {
        const key = e.divdept.trim().toLowerCase();
        if (!deptMap.has(key)) deptMap.set(key, e.divdept.trim());
      }
    }
    const deptList = Array.from(deptMap.values())
      .sort((a, b) => a.localeCompare(b, undefined, { sensitivity: "base" }));

    // ---------- DOM targets ----------
    const container = document.getElementById("directory");
    if (!container) throw new Error("Missing #directory mount element");
    container.innerHTML = "";

    // Filtering UI wrapper
    let filtering = document.querySelector(".directory-filtering");
    if (!filtering) {
      filtering = document.createElement("div");
      filtering.className = "directory-filtering";
      filtering.innerHTML = `
        <div class="directory-filtering-start">
          <div class="form-group">
            <label for="directory-search">Search</label>
            <input type="text" class="form-control" id="directory-search"
                   placeholder="Type a name, department, or keyword" />
          </div>
        </div>
        <div class="directory-filtering-end"></div>
      `;
      container.appendChild(filtering);
    } else {
      container.appendChild(filtering);
    }
    const searchInput = filtering.querySelector("#directory-search");
    const filteringEnd = filtering.querySelector(".directory-filtering-end");

    // ---------- Department Dropdown (with inline search) ----------
    const dd = document.createElement("div");
    dd.className = "directory-dept-dropdown";

    const ddId = "dept-dropdown";
    const fallbackMenuId = ddId + "-menu";
    const labelId = ddId + "-label";
    const summaryId = ddId + "-summary";

    const ddLabel = document.createElement("label");
    ddLabel.id = labelId;
    ddLabel.className = "directory-dept-label";
    ddLabel.textContent = "Filters";
    dd.appendChild(ddLabel);

    const ddBtnWrapper = document.createElement("div");
    dd.appendChild(ddBtnWrapper);

    const ddBtn = document.createElement("button");
    ddBtn.type = "button";
    ddBtn.className = "directory-dept-button";
    ddBtn.setAttribute("aria-haspopup", "dialog");
    ddBtn.setAttribute("aria-expanded", "false");
    ddBtn.setAttribute("aria-labelledby", `${labelId} ${summaryId}`);
    ddBtn.innerHTML = `
      <span id="${summaryId}">All Departments</span>
      <span class="sr-only">, press Enter to open</span>
    `;
    ddBtnWrapper.appendChild(ddBtn);

    let ddMenu = document.getElementById("dept-dropdown-menu");
    if (!ddMenu) {
      ddMenu = document.createElement("div");
      ddMenu.id = fallbackMenuId;
    }
    ddMenu.classList.add("directory-dept-menu");
    ddMenu.setAttribute("hidden", "hidden");
    ddMenu.setAttribute("role", "group");
    ddMenu.setAttribute("aria-labelledby", labelId);

    const live = document.createElement("div");
    live.className = "sr-only";
    live.setAttribute("aria-live", "polite");
    ddBtnWrapper.appendChild(live);

    // Search box inside dropdown
    const filterWrap = document.createElement("div");
    filterWrap.className = "dept-filter-wrap";
    filterWrap.innerHTML = `
      <label class="sr-only" for="dept-filter-input">Search departments</label>
      <input type="text" id="dept-filter-input" class="dept-filter-input form-control"
             placeholder="Filter departments…" autocomplete="off" />
    `;
    ddMenu.appendChild(filterWrap);

    // "All" option
    const allWrap = document.createElement("label");
    allWrap.className = "directory-dept-option";
    allWrap.innerHTML = `
      <input type="checkbox" class="dept-all" checked />
      <span>All Departments</span>
    `;
    ddMenu.appendChild(allWrap);

    // Individual department checkboxes
    deptList.forEach((dept) => {
      const id = "dept_" + dept.replace(/\W+/g, "_").toLowerCase();
      const lbl = document.createElement("label");
      lbl.className = "directory-dept-option dept-option";
      lbl.setAttribute("for", id);
      lbl.dataset.deptLabel = dept.toLowerCase();
      lbl.innerHTML = `
        <input type="checkbox" id="${id}" class="dept-item" value="${dept}" />
        <span>${dept}</span>
      `;
      ddMenu.appendChild(lbl);
    });

    filteringEnd.appendChild(dd);
    ddBtnWrapper.appendChild(ddMenu);

    // Behavior
    const allCb = ddMenu.querySelector(".dept-all");
    let itemCbs = Array.from(ddMenu.querySelectorAll(".dept-item"));
    const filterInput = ddMenu.querySelector("#dept-filter-input");

    function syncAllCheckbox() {
      if (selectedDepts.size === 0 || selectedDepts.size === deptList.length) {
        allCb.checked = true;
        itemCbs.forEach(cb => { cb.checked = false; });
      } else {
        allCb.checked = false;
        itemCbs.forEach(cb => { cb.checked = selectedDepts.has(cb.value); });
      }
    }
    function updateDeptButtonLabel() {
      let text;
      if (selectedDepts.size === 0 || selectedDepts.size === deptList.length) {
        text = "All Departments";
      } else {
        text = Array.from(selectedDepts)
          .sort((a, b) => a.localeCompare(b, undefined, { sensitivity: "base" }))
          .join(", ");
      }
      document.getElementById(summaryId).textContent = text;
      live.textContent = `Departments selected: ${text}.`;
    }
    function openMenu() {
      ddMenu.removeAttribute("hidden");
      ddBtn.setAttribute("aria-expanded", "true");
      if (filterInput) filterInput.focus();
    }
    function closeMenu(returnFocus = true) {
      ddMenu.setAttribute("hidden", "hidden");
      ddBtn.setAttribute("aria-expanded", "false");
      if (returnFocus) ddBtn.focus();
    }
    function toggleMenu() {
      if (ddMenu.hasAttribute("hidden")) openMenu(); else closeMenu();
    }

    ddBtn.addEventListener("click", toggleMenu);
    ddBtn.addEventListener("keydown", (e) => {
      if (e.key === "Enter" || e.key === " " || e.key === "ArrowDown") {
        e.preventDefault(); openMenu();
      }
    });
    document.addEventListener("click", (e) => {
      if (!dd.contains(e.target)) closeMenu(false);
    });
    ddMenu.addEventListener("keydown", (e) => {
      const visibleCbs = [allCb, ...Array.from(ddMenu.querySelectorAll(".dept-item"))
        .filter(cb => cb.closest(".dept-option")?.style.display !== "none")];
      const idx = visibleCbs.indexOf(document.activeElement);
      if (e.key === "Escape") { e.preventDefault(); closeMenu(true); }
      if (e.key === "ArrowDown") {
        e.preventDefault();
        const next = visibleCbs[Math.min(idx + 1, visibleCbs.length - 1)] || visibleCbs[0];
        next.focus();
      }
      if (e.key === "ArrowUp") {
        e.preventDefault();
        const prev = visibleCbs[Math.max(idx - 1, 0)] || visibleCbs[0];
        prev.focus();
      }
    });

    allCb.addEventListener("change", () => {
      if (allCb.checked) {
        selectedDepts.clear();
        updateDeptButtonLabel(); syncAllCheckbox(); render();
      }
    });
    itemCbs.forEach(cb => {
      cb.addEventListener("change", () => {
        if (cb.checked) selectedDepts.add(cb.value); else selectedDepts.delete(cb.value);
        if (selectedDepts.size === deptList.length) selectedDepts.clear();
        updateDeptButtonLabel(); syncAllCheckbox(); render();
      });
    });

    function filterDeptOptions(q) {
      const query = (q || "").trim().toLowerCase();
      const labels = ddMenu.querySelectorAll(".dept-option");
      labels.forEach(lbl => {
        const name = lbl.dataset.deptLabel || lbl.textContent.toLowerCase();
        const show = query === "" || name.startsWith(query);
        lbl.style.display = show ? "" : "none";
      });
      itemCbs = Array.from(ddMenu.querySelectorAll(".dept-item"));
      syncAllCheckbox();
      const anyVisible = Array.from(labels).some(l => l.style.display !== "none");
      if (!anyVisible && document.activeElement !== filterInput) filterInput.focus();
    }
    let filterTimer = null;
    filterInput.addEventListener("input", () => {
      if (filterTimer) clearTimeout(filterTimer);
      filterTimer = setTimeout(() => filterDeptOptions(filterInput.value), 80);
    });
    filterInput.addEventListener("keydown", (e) => {
      if (e.key === "Escape" && filterInput.value) {
        e.preventDefault();
        filterInput.value = "";
        filterDeptOptions("");
      }
    });

    updateDeptButtonLabel();
    syncAllCheckbox();

    // ---------- Search handling (debounced) ----------
    let searchTimer = null;
    searchInput?.addEventListener("input", () => {
      if (searchTimer) clearTimeout(searchTimer);
      searchTimer = setTimeout(() => {
        searchQuery = (searchInput.value || "").trim().toLowerCase();
        render();
      }, 150);
    });

    // ---------- Render (A–Z index + groups + items) ----------
    const listMount = document.createElement("div");
    listMount.className = "directory-mount";
    container.appendChild(listMount);

    function passesSearch(emp) {
      if (!searchQuery) return true;
      const hay = [
        emp.firstname, emp.middlename, emp.lastname,
        emp.name, emp.jobtitle, emp.divdept, emp.phone
      ].filter(Boolean).join(" ").toLowerCase();
      return hay.indexOf(searchQuery) !== -1;
    }
    function passesDept(emp) {
      if (selectedDepts.size === 0) return true; // All
      const d = (emp.divdept || "").trim();
      return d && selectedDepts.has(d);
    }
    function buildIndexBar(lettersInUse) {
      const bar = document.createElement("div");
      bar.className = "directory-index";
      const barInner = document.createElement("div");
      barInner.className = "directory-index-inner";
      bar.appendChild(barInner);
      for (let i = 65; i <= 90; i++) {
        const letter = String.fromCharCode(i);
        const link = document.createElement("a");
        link.href = `#letter-${letter}`;
        link.textContent = letter;
        if (!lettersInUse.has(letter)) {
          link.className = "disabled";
          link.href = "javascript:void(0)";
          link.setAttribute("aria-disabled", "true");
        }
        barInner.appendChild(link);
        barInner.appendChild(document.createTextNode(" "));
      }
      return bar;
    }

    function render() {
      listMount.innerHTML = "";

      const filtered = employees.filter(e => passesSearch(e) && passesDept(e));

      const wrapper = document.createElement("div");
      wrapper.className = "directory-wrapper";

      const lettersInUse = new Set();
      filtered.forEach(emp => {
        const li = emp.lastname && emp.lastname[0] ? emp.lastname[0].toUpperCase() : "#";
        if (/[A-Z]/.test(li)) lettersInUse.add(li);
      });

      wrapper.appendChild(buildIndexBar(lettersInUse));

      let currentLetter = null;

      filtered.forEach(emp => {
        const lastInitial = emp.lastname && emp.lastname[0]
          ? emp.lastname[0].toUpperCase()
          : "#";

        if (lastInitial !== currentLetter) {
          currentLetter = lastInitial;

          const letterHeader = document.createElement("h2");
          letterHeader.id = `letter-${currentLetter}`;
          letterHeader.textContent = currentLetter;
          letterHeader.className = "directory-letter";
          wrapper.appendChild(letterHeader);
        }

        // Row
        const directoryItem = document.createElement("div");
        directoryItem.className = "directory-item";

        // --- LEFT ---
        const start = document.createElement("div");
        start.className = "directory-item-start";

        const nameContainer = document.createElement("div");
        nameContainer.className = "directory-item-name";

        const fullName = [emp.firstname, emp.middlename, emp.lastname]
          .filter(v => v && v.trim() !== "")
          .join(" ");
        if (fullName) {
          const h3 = document.createElement("h3");
          h3.textContent = fullName;
          nameContainer.appendChild(h3);
        }

        if (emp.jobtitle && emp.jobtitle.trim() !== "") {
          const title = document.createElement("div");
          title.className = "directory-item-title";
          title.textContent = emp.jobtitle;
          nameContainer.appendChild(title);
        }

        if (emp.divdept && emp.divdept.trim() !== "") {
          const dept = document.createElement("div");
          dept.className = "directory-item-department";
          dept.innerHTML = `<span class="fa fa-building-columns"></span> <span>${emp.divdept}</span>`;
          nameContainer.appendChild(dept);
        }

        start.appendChild(nameContainer);

        // --- RIGHT ---
        const end = document.createElement("div");
        end.className = "directory-item-end";

        if (emp.extension && emp.extension.trim() !== "") {
          const phone = document.createElement("div");
          phone.className = "directory-item-phone";
          phone.innerHTML = `<span class="fa fa-phone"></span> <span>(562) 860-2451 (Ext. ${emp.extension})</span>`;
          end.appendChild(phone);
        }

        // ==== Email actions (encode in DOM; decode on click) ====
        if (emp.emailaddr && emp.emailaddr.trim() !== "") {
          const email = document.createElement("div");
          email.className = "directory-item-email";
          const encodedEmail = encodeLikeXsl(emp.emailaddr.trim());

          // We don't expose the email in href. We store it encoded in data-attr.
          email.innerHTML = `
            <a href="#" class="email-mailto" data-enc="${encodedEmail}">
              <span class="fa fa-paper-plane"></span> Email
            </a>
            <a href="#" class="email-copy" data-enc="${encodedEmail}">
              <span class="fa fa-copy"></span> <span class="sr-only">Copy</span>
            </a>
            <span class="copy-feedback" aria-live="polite"></span>
          `;
          end.appendChild(email);
        }

        directoryItem.appendChild(start);
        directoryItem.appendChild(end);
        wrapper.appendChild(directoryItem);
      });

      listMount.appendChild(wrapper);
      updateDeptButtonLabel();
      syncAllCheckbox();
    }

    // Event delegation for email actions
    container.addEventListener("click", async (e) => {
      const a = e.target.closest("a");
      if (!a) return;

      // mailto
      if (a.classList.contains("email-mailto")) {
        e.preventDefault();
        const enc = a.getAttribute("data-enc") || "";
        const address = decodeLikeXsl(enc);
        if (address) {
          // Open mail client
          window.location.href = "mailto:" + address;
        }
      }

      // copy
      if (a.classList.contains("email-copy")) {
        e.preventDefault();
        const enc = a.getAttribute("data-enc") || "";
        const address = decodeLikeXsl(enc);
        const feedback = a.parentElement?.querySelector(".copy-feedback");
        try {
          if (navigator.clipboard?.writeText) {
            await navigator.clipboard.writeText(address);
          } else {
            // fallback
            const ta = document.createElement("textarea");
            ta.value = address;
            ta.style.position = "fixed";
            ta.style.opacity = "0";
            document.body.appendChild(ta);
            ta.focus();
            ta.select();
            document.execCommand("copy");
            document.body.removeChild(ta);
          }
          if (feedback) {
            feedback.textContent = "Copied!";
            setTimeout(() => (feedback.textContent = ""), 1200);
          }
        } catch (err) {
          if (feedback) feedback.textContent = "Copy failed";
          setTimeout(() => (feedback.textContent = ""), 1500);
          console.error("Copy failed:", err);
        }
      }
    });

    // Initial render
    render();
    hideDirectoryLoader();

  } catch (err) {
    hideDirectoryLoader();
    console.error(err);
    const target = document.getElementById("directory");
    if (target) {
      target.textContent = err && err.message
        ? ("Directory error: " + err.message)
        : "Error loading directory. Please refresh the page.";
    }
  }
}