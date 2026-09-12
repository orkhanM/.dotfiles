"""ptpython config: vi mode, catppuccin mocha. Stowed to ~/.config/ptpython.

Set THEME below, or flip live with F2 -> Colorscheme. Catppuccin code
highlighting needs the pygments plugin in ptpython's venv (`make ptpython`
installs it); without it only the UI palette applies.

appdirs looks in ~/Library/Application Support on macOS, not ~/.config, so
this is found via PTPYTHON_CONFIG_HOME from .zshrc plus a symlink from
`make post-stow`. Linux needs neither.
"""

from prompt_toolkit.output import ColorDepth
from prompt_toolkit.styles import Style
from ptpython.python_input import (
    CompletePrivateAttributes,
    CompletionVisualisation,
)

THEME = "catppuccin-mocha"          # or "solarized-dark"


def _ui_palette(bg, bg_alt, dim, fg, fg_bright, accent, err, warn, ok, info,
                sel_bg, meta, meta_bg):
    """Map semantic colours onto the ~50 style classes ptpython looks up.

    ptpython only ships "default" and "blue" for its own chrome, so the
    palette is hand-rolled. meta/meta_bg stay separate from dim/bg_alt
    because reusing dim on the menu's meta column lands ~2.5:1 contrast.
    """
    return {
        # Prompt and the In[n]/Out[n] markers
        "prompt": f"{accent} bold",
        "prompt.dots": dim,
        "in": f"{accent} bold",
        "in.number": dim,
        "out": f"{err} bold",
        "out.number": dim,
        # completion menu. prompt_toolkit hardcodes fuzzymatch.outside to
        # #444444, ~1.3:1 on a dark menu, so unmatched characters are
        # invisible. fuzzy completion puts most of every entry in that class,
        # so without these two overrides the menu is unreadable.
        "completion-menu": f"bg:{bg_alt} {fg}",
        "completion": f"bg:{bg_alt} {fg}",
        "completion-menu.completion": f"bg:{bg_alt} {fg}",
        "completion-menu.completion fuzzymatch.outside": meta,
        "completion-menu.completion fuzzymatch.inside": f"{accent} bold",
        "completion-menu.completion fuzzymatch.inside.character": "underline",
        "completion-menu.completion.current fuzzymatch.outside": fg_bright,
        "completion-menu.completion.current fuzzymatch.inside": f"{fg_bright} bold",
        "completion-menu.completion.current": f"bg:{sel_bg} {fg_bright} bold",
        "completion-menu.meta.completion": f"bg:{meta_bg} {meta}",
        "completion-menu.meta.completion.current": f"bg:{sel_bg} {fg_bright}",
        "completion-menu.multi-column-meta": f"bg:{meta_bg} {meta}",
        "scrollbar.background": f"bg:{bg_alt}",
        "scrollbar.button": f"bg:{sel_bg}",
        "completion.builtin": info,
        "completion.param": f"{fg} italic",
        "completion.keyword": ok,
        "completion.keyword fuzzymatch.inside": f"{ok} bold",
        "completion.keyword fuzzymatch.outside": meta,
        # Signature / docstring popups
        "signature-toolbar": f"bg:{bg_alt} {fg}",
        "signature-toolbar current-name": f"bg:{sel_bg} {fg_bright} bold",
        "signature-toolbar operator": f"bg:{bg_alt} {fg_bright}",
        "docstring": dim,
        # Status bar
        "status-toolbar": f"bg:{bg_alt} {fg}",
        "status-toolbar.title": fg_bright,
        "status-toolbar.inputmode": f"{info} bold",
        "status-toolbar.input-mode": f"{info} bold",
        "status-toolbar.key": f"bg:{sel_bg} {fg_bright}",
        "status-toolbar key": f"bg:{sel_bg} {fg_bright}",
        "status-toolbar more": warn,
        "status-toolbar.pythonversion": dim,
        "status-toolbar.pastemodeon": f"bg:{warn} {bg} bold",
        "status-toolbar paste-mode-on": f"bg:{warn} {bg} bold",
        "record": f"bg:{err} {bg}",
        "system-toolbar": f"bg:{bg_alt} {ok}",
        "arg-toolbar": f"bg:{bg_alt} {fg}",
        "arg-toolbar.text": f"bg:{bg_alt} {fg_bright} bold",
        "validation-toolbar": f"bg:{err} {bg}",
        # F2 sidebar
        "sidebar": f"bg:{bg_alt} {fg}",
        "sidebar.title": f"bg:{accent} {bg} bold",
        "sidebar.label": f"bg:{bg_alt} {fg}",
        "sidebar.status": f"bg:{bg_alt} {info}",
        "sidebar.label selected": f"bg:{sel_bg} {fg_bright} bold",
        "sidebar.status selected": f"bg:{sel_bg} {ok} bold",
        "sidebar.separator": f"bg:{bg_alt} {dim} underline",
        "sidebar.key": f"bg:{bg_alt} {warn} bold",
        "sidebar.key.description": f"bg:{bg_alt} {fg}",
        "sidebar.helptext": f"bg:{bg_alt} {fg_bright}",
        # Misc chrome
        "separator": dim,
        "window-border": dim,
        "window-title": f"bg:{bg_alt} {fg_bright} bold",
        "accept-message": f"bg:{bg_alt} {ok}",
        "exit-confirmation": f"bg:{err} {bg} bold",
        "control-character": warn,
        # Search / selection / brackets
        "search-toolbar": f"bg:{bg_alt} {fg}",
        "search-toolbar.text": f"bg:{bg_alt} {fg_bright}",
        "selected-text": f"bg:{sel_bg} {fg_bright}",
        "matching-bracket.cursor": f"bg:{warn} {bg} bold",
        "matching-bracket.other": f"bg:{sel_bg} {fg_bright}",
        "line-number": dim,
        "line-number.current": f"{warn} bold",
        "bottom-toolbar": f"bg:{bg_alt} {fg}",
    }


UI_PALETTES = {
    # catppuccin mocha: base/surface0/overlay0/text/subtext1 + accents
    "catppuccin-mocha": _ui_palette(
        bg="#1e1e2e", bg_alt="#313244", dim="#7f849c",
        fg="#cdd6f4", fg_bright="#f5e0dc", sel_bg="#585b70",
        meta="#a6adc8", meta_bg="#181825",
        accent="#89b4fa", err="#f38ba8", warn="#fab387",
        ok="#a6e3a1", info="#94e2d5",
    ),
    # solarized dark: base03/base02/base01/base0/base1 + accents
    "solarized-dark": _ui_palette(
        bg="#002b36", bg_alt="#073642", dim="#657b83",
        fg="#839496", fg_bright="#fdf6e3", sel_bg="#586e75",
        meta="#839496", meta_bg="#002b36",
        accent="#268bd2", err="#dc322f", warn="#cb4b16",
        ok="#859900", info="#2aa198",
    ),
}


def configure(repl):
    # --- vi mode ---------------------------------------------------------
    repl.vi_mode = True
    # start in insert mode, esc for normal as usual
    repl.vi_start_in_navigation_mode = False
    repl.vi_keep_last_used_mode = False

    # --- colours ---------------------------------------------------------
    # truecolor, else the hex values quantise to the 256-colour cube
    repl.color_depth = ColorDepth.TRUE_COLOR

    # install all palettes so F2 -> Colorscheme can switch between them
    for name, palette in UI_PALETTES.items():
        repl.install_ui_colorscheme(name, Style.from_dict(palette))

    # code style comes from pygments, so skip it if the plugin is missing
    if THEME in repl.code_styles:
        repl.use_code_colorscheme(THEME)
    repl.use_ui_colorscheme(THEME)

    # ptpython dims colours toward the bg, which makes dark themes muddy
    repl.min_brightness = 0.20
    repl.max_brightness = 1.0

    # --- completion ------------------------------------------------------
    repl.complete_while_typing = True
    repl.enable_fuzzy_completion = True
    # grid layout, dunders hidden unless there's nothing else
    repl.completion_visualisation = CompletionVisualisation.MULTI_COLUMN
    repl.complete_private_attributes = CompletePrivateAttributes.IF_NO_PUBLIC
    # dict keys too. eval-based, so it runs code to inspect the object.
    repl.enable_dictionary_completion = True

    # --- behaviour -------------------------------------------------------
    repl.show_signature = True
    repl.show_docstring = True
    repl.show_status_bar = True
    repl.show_line_numbers = False
    repl.highlight_matching_parenthesis = True
    repl.enable_history_search = True
    repl.enable_auto_suggest = True
    repl.enable_open_in_editor = True     # v in normal mode -> $EDITOR
    repl.enable_system_bindings = True    # Meta-! for a shell command
    repl.enable_mouse_support = False     # keeps terminal text selection working
    repl.confirm_exit = False
    repl.insert_blank_line_after_output = True
