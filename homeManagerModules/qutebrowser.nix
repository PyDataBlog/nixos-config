{ ... }:
{
  programs.qutebrowser = {
    enable = true;
    loadAutoconfig = false;

    aliases = {
      q = "quit";
      w = "session-save";
      wq = "quit --save";
    };

    searchEngines = {
      DEFAULT = "https://duckduckgo.com/?q={}";
      g = "https://www.google.com/search?q={}";
      gh = "https://github.com/search?q={}";
      hm = "https://home-manager-options.extranix.com/?query={}";
      no = "https://search.nixos.org/options?channel=unstable&query={}";
      np = "https://search.nixos.org/packages?channel=unstable&query={}";
      nw = "https://wiki.nixos.org/w/index.php?search={}";
      yt = "https://www.youtube.com/results?search_query={}";
    };

    quickmarks = {
      gh = "https://github.com/";
      hm = "https://home-manager.dev/";
      no = "https://search.nixos.org/options?channel=unstable";
      np = "https://search.nixos.org/packages?channel=unstable";
      nw = "https://wiki.nixos.org/";
    };

    keyBindings.normal = {
      "<Ctrl-Shift-J>" = "devtools";
      "<Ctrl-Shift-R>" = "config-source";
    };

    settings = {
      auto_save.session = true;

      colors.completion.category.bg = "#3b4252";
      colors.completion.category.border.bottom = "#4c566a";
      colors.completion.category.border.top = "#4c566a";
      colors.completion.category.fg = "#eceff4";
      colors.completion.even.bg = "#2e3440";
      colors.completion.item.selected.bg = "#88c0d0";
      colors.completion.item.selected.fg = "#2e3440";
      colors.completion.match.fg = "#88c0d0";
      colors.completion.odd.bg = "#3b4252";
      colors.completion.scrollbar.bg = "#2e3440";
      colors.completion.scrollbar.fg = "#81a1c1";

      colors.statusbar.command.bg = "#2e3440";
      colors.statusbar.command.fg = "#eceff4";
      colors.statusbar.insert.bg = "#a3be8c";
      colors.statusbar.insert.fg = "#2e3440";
      colors.statusbar.normal.bg = "#2e3440";
      colors.statusbar.normal.fg = "#eceff4";
      colors.statusbar.url.error.fg = "#bf616a";
      colors.statusbar.url.hover.fg = "#88c0d0";
      colors.statusbar.url.success.http.fg = "#d8dee9";
      colors.statusbar.url.success.https.fg = "#a3be8c";
      colors.statusbar.url.warn.fg = "#ebcb8b";

      colors.tabs.bar.bg = "#2e3440";
      colors.tabs.even.bg = "#3b4252";
      colors.tabs.even.fg = "#d8dee9";
      colors.tabs.indicator.error = "#bf616a";
      colors.tabs.indicator.start = "#88c0d0";
      colors.tabs.indicator.stop = "#81a1c1";
      colors.tabs.odd.bg = "#434c5e";
      colors.tabs.odd.fg = "#d8dee9";
      colors.tabs.selected.even.bg = "#5e81ac";
      colors.tabs.selected.even.fg = "#eceff4";
      colors.tabs.selected.odd.bg = "#5e81ac";
      colors.tabs.selected.odd.fg = "#eceff4";

      colors.webpage.darkmode.enabled = true;
      colors.webpage.preferred_color_scheme = "dark";

      completion.open_categories = [
        "searchengines"
        "quickmarks"
        "bookmarks"
        "history"
        "filesystem"
      ];

      content.blocking.method = "both";
      content.pdfjs = true;

      downloads.location.directory = "~/Downloads";
      downloads.location.prompt = false;

      editor.command = [
        "ghostty"
        "-e"
        "nvim"
        "{file}"
        "-c"
        "normal {line}G{column0}l"
      ];

      fonts.default_family = [
        "Ubuntu Mono"
        "monospace"
      ];
      fonts.default_size = "11pt";
      fonts.web.family.fixed = "Ubuntu Mono";

      statusbar.show = "in-mode";

      tabs.last_close = "default-page";
      tabs.position = "left";
      tabs.show = "multiple";
      tabs.title.format = "{audio}{current_title}";
      tabs.title.format_pinned = "{index}";

      url.default_page = "https://start.duckduckgo.com/";
      url.start_pages = [ "https://start.duckduckgo.com/" ];
    };
  };
}
