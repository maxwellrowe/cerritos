# Modern Campus Pages and Sections

## Overview

This site now relies primarily on one current page template for standard interior content pages:

- `dept-inside.xsl`

Most other XSL page templates in the codebase are legacy and should only be used when maintaining older content that depends on legacy behavior.

In Modern Campus:

- **New Page** is the standard option for creating a new interior content page
- **Subsite** is the standard option for creating a new section structure

## Template Mapping

### New Page

The **New Page** option maps to:

- TCF: `_resources/templates/01_dept-inside.tcf`
- Output template: `01_dept-inside.tmpl`
- XSL page type: `_resources/xsl/dept-inside.xsl`

This is the main template authors should use for most new content pages.

### Subsite

The **Subsite** option maps to:

- TCF: `_resources/templates/12_subsite.tcf`

This is used to create a new section folder along with the standard supporting files for that section.

## How The Page Structure Works

The current page structure is split between:

- `_resources/xsl/dept-inside.xsl`
- `_resources/xsl/common.xsl`
- `_resources/xsl/_shared/sidebar.xsl`
- `_resources/xsl/_shared/breadcrumbs.xsl`

### `dept-inside.xsl`

`dept-inside.xsl` controls the page body layout through the `page-content` template.

Its main behaviors are:

- If `page-fullwidth = true`, the page renders full width with no sidebar
- Otherwise, it renders the standard interior layout:
  - main content area
  - optional sidebar

The main editable page region is:

- `document/ouc:div[@label='maincontent']`

### `common.xsl`

`common.xsl` provides the shared page shell for the site, including:

- `<head>` output
- site header and footer
- breadcrumbs
- page hero / page title area
- CSS and JS includes
- shared page properties and layout logic

`dept-inside.xsl` imports `common.xsl`, so most shared page behavior comes from there.

## Sidebar Structure

Sidebar logic is handled in `_resources/xsl/_shared/sidebar.xsl`.

The sidebar has two main optional parts:

- section navigation
- department / section information

These are rendered through:

- `sidebar-nav`
- `sidebar-info`

There is also a mobile version of the navigation:

- `sidebar-nav-mobile`

## How Navigation and Section Info Are Loaded

The section sidebar usually depends on:

- `deptnav.inc`
- `deptinfo.inc`

The system looks for those files in a specific order.

### Section navigation lookup

The navigation include path is resolved in this order:

1. `LeftNav` page property
2. inherited `props_LeftNav` from `_props.pcf`
3. nearest `deptnav.inc` found by searching upward in the section

### Department info lookup

The department info include path is resolved in this order:

1. `DeptInfo` page property
2. inherited `props_DeptInfo` from `_props.pcf`
3. nearest `deptinfo.inc` found by searching upward in the section

This allows:

- a section to share one navigation include and one department info include across many pages
- individual pages to override those defaults when needed

## What New Page Prompts For

The **New Page** template prompts for:

- filename
- page title / heading
- author
- description
- keywords
- optional `LeftNav`
- optional `DeptInfo`

In most cases:

- `LeftNav` should be left blank unless the page needs a custom navigation include
- `DeptInfo` should be left blank unless the page needs a custom department info include

If those fields are blank, the page will usually inherit the section defaults.

## What Subsite Creates

The **Subsite** template creates a new section folder and several supporting files.

Common outputs include:

- `_props.pcf`
- `_includes/assets/default.css`
- `_includes/assets/deptnav.pcf`
- `_includes/assets/deptinfo.pcf`
- `_includes/assets/gallery.xml`
- `_includes/images/placeholder.gif`
- `_includes/docs/placeholder.txt`
- a default section page created from `02_dept-home.tmpl`

This makes **Subsite** the recommended starting point for a brand-new section.

## Key Page Properties

These are some of the most important properties used by the current page structure.

### Layout and sidebar

- `page-fullwidth`
  - renders the page without the standard sidebar layout

- `hide-left-nav`
  - hides the section navigation

- `hide-dept-info`
  - hides the department info box

### Sidebar overrides

- `LeftNav`
  - overrides the default section navigation include for a specific page

- `DeptInfo`
  - overrides the default section info include for a specific page

### Page header and breadcrumbs

- `hide-breadcrumbs`
  - suppresses breadcrumb output

- `legacy-breadcrumbs`
  - forces the older breadcrumb system when needed

- `custom-hero`
  - uses a custom hero region instead of the default page title area

- `hide-page-title`
  - hides the default page title output

- `BrcPageTitle`
  - sets a custom breadcrumb title for the current page

### Styling and tracking

- `WebCss`
  - loads a custom stylesheet for a page or section
  - if not set on the page, the system can fall back to inherited `props_WebCss`

- `TrackingInclude`
  - injects a tracking include file into the page head

- `body_id`
  - adds a custom `id` to the `<body>` element for page-specific styling or scripting

## Recommended Workflow

### To create a new section

1. Use **Subsite**
2. Enter the new directory name and section title
3. Review the generated `_props.pcf`
4. Update the section navigation in `deptnav`
5. Update the section information in `deptinfo`
6. Add additional content pages using **New Page**

### To create a new page inside an existing section

1. Use **New Page**
2. Enter the page title, filename, and metadata
3. Leave `LeftNav` and `DeptInfo` blank unless an override is needed
4. Add content in the `maincontent` region
5. Adjust page properties only when a page needs custom behavior

## Best Practices

- Use **Subsite** to establish a new section instead of creating folder structures manually
- Use **New Page** for most new interior pages
- Treat `dept-inside.xsl` as the primary current template
- Keep `deptnav` and `deptinfo` at the section level whenever possible
- Use page-level overrides only when a single page needs behavior different from the rest of the section
- Avoid using older legacy templates unless a page specifically depends on them

## Troubleshooting Notes

- If a page is missing its sidebar, check:
  - `page-fullwidth`
  - `hide-left-nav`
  - `hide-dept-info`

- If the wrong section navigation appears, check:
  - the page-level `LeftNav` property
  - inherited `props_LeftNav`
  - where the nearest `deptnav.inc` is located

- If the wrong section info appears, check:
  - the page-level `DeptInfo` property
  - inherited `props_DeptInfo`
  - where the nearest `deptinfo.inc` is located

- If a page does not match the current site structure, verify that it was created from **New Page** and not from a legacy template

## Quick Summary

- **New Page** = standard content page using `dept-inside.xsl`
- **Subsite** = new section structure using `_resources/templates/12_subsite.tcf`
- shared framework = `common.xsl`
- section sidebar = `deptnav` + `deptinfo`
- most day-to-day page building should stay within this structure
