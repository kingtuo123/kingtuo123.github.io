---
layout: default
title: ip命令详解
parent: Linux命令
grand_parent: Linux
nav_order: 1
---

## Main navigation

The main navigation for your Just the Docs site is on the left side of the page at large screens and on the top (behind a tap) on small screens. The main navigation can be structured to accommodate a multi-level menu system (pages with children and grandchildren).

By default, all pages will appear as top level pages in the main nav unless a parent page is defined (see [Pages with Children](#pages-with-children)).

---

## Ordering pages

To specify a page order, use the `nav_order` parameter in your pages' YAML front matter.

#### Example
{: .no_toc }

```yaml
---
layout: default
title: Customization
nav_order: 4
---
```

