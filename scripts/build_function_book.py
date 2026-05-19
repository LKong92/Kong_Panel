from __future__ import annotations

import html
import json
import math
import re
from collections import Counter, defaultdict
from datetime import date
from pathlib import Path


SCRIPT_ROOT = Path(__file__).resolve().parents[1]
if (SCRIPT_ROOT / "Kong_Panel_20260518_GitHub" / "src").exists():
    ROOT = SCRIPT_ROOT / "Kong_Panel_20260518_GitHub"
else:
    ROOT = SCRIPT_ROOT
SRC = ROOT / "src"
DOCS = ROOT / "docs"
ASSETS = DOCS / "assets"
UPDATE_LOG = DOCS / "KP_update_log_raw.txt"
BRAND = "𝑲𝑶𝑵𝑮 Panel"


ENTRY_RE = re.compile(
    r"^\s*(?P<static>Static\s+)?(?P<kind>Function(?:/[A-Za-z]+)?|Proc|Window|Macro|Menu)\s+"
    r"(?P<name>[A-Za-z_][A-Za-z0-9_]*|\"[^\"]+\")",
    re.IGNORECASE,
)
CONTROL_RE = re.compile(
    r"^\s*(?P<kind>Button|SetVariable|PopupMenu|CheckBox|Slider|TabControl)\s+"
    r"(?P<name>[A-Za-z0-9_]+).*?\bproc=(?P<proc>[A-Za-z_][A-Za-z0-9_]*)"
)
CONTROL_LINE_RE = re.compile(
    r"^\s*(?P<kind>Button|SetVariable|PopupMenu|CheckBox|Slider|TabControl)\s+"
    r"(?P<name>[A-Za-z0-9_]+)\b(?P<attrs>.*)"
)
WINDOW_START_RE = re.compile(r"^\s*Window\s+(?P<name>[A-Za-z_][A-Za-z0-9_]*)", re.IGNORECASE)
POS_RE = re.compile(r"pos=\{(?P<x>-?\d+(?:\.\d+)?),(?P<y>-?\d+(?:\.\d+)?)\}")
SIZE_RE = re.compile(r"size=\{(?P<w>-?\d+(?:\.\d+)?),(?P<h>-?\d+(?:\.\d+)?)\}")
TITLE_RE = re.compile(r'title=\"(?P<title>(?:\\\\.|[^\"])*)\"')
PROC_RE = re.compile(r"\bproc=(?P<proc>[A-Za-z_][A-Za-z0-9_]*)")
WIN_RE = re.compile(r"\bwin=\$?(?P<win>[A-Za-z_][A-Za-z0-9_]*(?:\([^)]*\))?)")
DISABLE_RE = re.compile(r"\bdisable=(?P<disable>-?\d+)")
DRAW_TEXT_RE = re.compile(
    r"^\s*DrawText(?:/W=\$?[A-Za-z_][A-Za-z0-9_]*(?:\([^)]*\))?)?\s+"
    r"(?P<x>-?\d+(?:\.\d+)?),(?P<y>-?\d+(?:\.\d+)?),\"(?P<text>(?:\\\\.|[^\"])*)\""
)
EXECUTE_RE = re.compile(r'Execute\s+\"\s*(?P<command>[A-Za-z_][A-Za-z0-9_]*)\(')
CALL_RE = re.compile(r"\b([A-Za-z_][A-Za-z0-9_]*)\s*\(")
PROMPT_RE = re.compile(r'^\s*Prompt?\s+([A-Za-z_][A-Za-z0-9_]*)\s*,\s*"([^"]+)"', re.IGNORECASE)
DECL_RE = re.compile(
    r"^\s*(?:Variable|String|Wave|NVAR|SVAR|WAVE|DFREF)\s+(?P<names>[^/;]+?)(?:\s*//\s*(?P<comment>.*))?$",
    re.IGNORECASE,
)
ASSIGN_RE = re.compile(r"^\s*(?P<name>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?P<value>[^/;]+)")

CALL_EXCLUDE = {
    "abs",
    "acos",
    "asin",
    "atan",
    "cmpstr",
    "cmplx",
    "cos",
    "datafolderexists",
    "dimdelta",
    "dimoffset",
    "dimsize",
    "enoise",
    "exists",
    "exp",
    "floor",
    "imag",
    "itemsinlist",
    "igorinfo",
    "ln",
    "lowerstr",
    "mod",
    "num2str",
    "parsefilepath",
    "possiblyquotename",
    "real",
    "round",
    "sin",
    "sqrt",
    "stringbykey",
    "stringfromlist",
    "strlen",
    "strsearch",
    "strswitch",
    "sum",
    "tan",
    "tracenamelist",
    "uniqueName".lower(),
    "v_flag",
    "waveexists",
    "wavelist",
    "wavemax",
    "wavemin",
    "winlist",
    "winname",
    "getdatafolder",
    "getdatafolderdfr",
    "geterrmessage",
    "getrterror",
    "nameofwave",
    "nameOfWave".lower(),
    "replacestring",
    "selectstring",
}

IGOR_COMMAND_PATTERNS = [
    (r"\bFFT\b|\bIFFT\b", "performs Fourier-transform or inverse-transform operations"),
    (r"\bCurveFit\b|\bFuncFit\b|\bMultiPeakFit\b", "runs fitting routines on spectra, curves, or map-derived traces"),
    (r"\bMake\b", "creates output waves"),
    (r"\bDuplicate\b", "duplicates or stages waves for downstream processing"),
    (r"\bRedimension\b", "reshapes existing waves"),
    (r"\bSetScale\b", "assigns Igor axis scaling/units to the output"),
    (r"\bDisplay\b|\bAppendToGraph\b|\bAppendImage\b|\bAppendMatrixContour\b|\bAppend\b", "opens or updates graph/image displays"),
    (r"\bModifyGraph\b|\bModifyImage\b|\bLabel\b|\bSetAxis\b|\bTextBox\b", "formats graph axes, labels, colors, or annotations"),
    (r"\bImageStats\b|\bWaveStats\b", "extracts image/wave statistics"),
    (r"\bMatrixOP\b", "uses Igor matrix operations for vectorized calculation"),
    (r"\bSmooth\b", "smooths wave data"),
    (r"\bDifferentiate\b", "differentiates wave data"),
    (r"\bIntegrate\b", "integrates wave data"),
    (r"\bOpen\b|\bLoadWave\b|\bGBLoadWave\b|\bNewPath\b", "loads data from files or paths"),
    (r"\bSave\b|\bfprintf\b|\bFStatus\b", "writes or exports data"),
    (r"\bNewDataFolder\b|\bSetDataFolder\b|\bKillDataFolder\b", "creates, switches, or removes Igor data folders"),
    (r"\bControlInfo\b|\bModifyControl\b|\bSetVariable\b|\bPopupMenu\b|\bButton\b", "reads or updates panel controls"),
    (r"\bKillWaves\b|\bKillWindow\b|\bDoWindow\b", "cleans up waves/windows or brings an existing window forward"),
    (r"\bDoPrompt\b|\bPrompt\b", "asks the user for parameters through Igor prompts"),
]

DOMAIN_RULES = [
    (r"nanonis|3ds|sxm|nsp|topo|grid|gate", "Nanonis/STM data loading or map conversion"),
    (r"fft|fourier|filter|qpi|qvec|phase|lockin", "FFT, QPI, phase, or lock-in analysis"),
    (r"sym|c4|d4|mirror|reflect", "symmetry or reflection processing"),
    (r"linecut|slice|cut|extract|marquee", "linecut, slice, or region extraction"),
    (r"interp|pad|rescale|scale|resize|redimension", "matrix resampling, scaling, or reshaping"),
    (r"rot|rotate|shear|drift|strain", "geometric correction, rotation, shear, drift, or strain analysis"),
    (r"smooth|norm|normalize|background|bkg|trend", "smoothing, normalization, or background removal"),
    (r"gap|bcs|dyne|dynes|superconduct|vortex|cdgm|mzm|majorana|dos", "spectroscopy, superconducting-gap, or vortex-model analysis"),
    (r"haldane|qiwuzhang|qwz|qhz|hughes|\btopological\b|berry|chern", "topological-model simulation"),
    (r"tbg|ttg|moire|honeycomb|triangular|square|lattice|twist", "lattice, moire, or twist-angle simulation/analysis"),
    (r"arpes|edc|mdc|fermi|kz|kx|ky|momentum|hv|scienta", "ARPES-style loading, plotting, or momentum conversion"),
    (r"color|ctab|format|label|axis|graph|window|table|layout|display", "graph display, formatting, or window management"),
    (r"matrix|wave|cube|3d|2d|1d", "Igor wave/matrix/cube data operation"),
]

CATEGORY_RULES = [
    (
        "Start Here: Main Panel, Menus, and Window Entries",
        r"kong_igor_panel|kongpanel|load_kongpanel|mainpanel|^initialize$|^menu$|resize controls",
    ),
    (
        "Nanonis, STM, and STS Loading",
        r"nanonis|3ds|sxm|nsp|unisoku|autoloadgrid|autonanis|gatemap|topo|z_r_rho|grid|sts|load individual|kp_loadnanonis",
    ),
    (
        "Smart Display, Graph Formatting, and Figure Tools",
        r"smartdisplay|smart_3d|display|graph|layout|movie|color|ctab|zcolor|format|label|axis|waterfall|cycle color|transfergraph|capture|window|table",
    ),
    (
        "FFT, QPI, Fourier Filters, Phase, and Lock-In",
        r"fft|fourier|filter|qpi|pr_qpi|phase|lockin|lock-in|gp[a-z]?|qvec|ftlinecut|phase dif|line@2d",
    ),
    (
        "Matrix, Cube, Wave, and Batch Operations",
        r"matrix|cube|wave|mat3d|interp|pad|rescale|scale|resize|deletepoints|duplicate|rename|coarsem|partial|marquee|smooth|normalize|linkstsmap|gridtolinecut",
    ),
    (
        "Spectroscopy, Gap, Peak, and Fitting Workflows",
        r"gap|peak|multipeak|curvefit|funcfit|gauss|gcb|bcs|dyne|dynes|sc-sc|dos|edc|mdc|d[iI]/d[vV]|normalization|tip height|divider",
    ),
    (
        "ARPES Template and Momentum Conversion",
        r"arpes|scienta|fermi|kz|kx|ky|momentum|angle|hv|edc|mdc|fs|theta|pierre|template|curvature",
    ),
    (
        "Lattice, Moire, Symmetry, Drift, and Strain",
        r"lattice|moire|moir|honeycomb|triangular|square|twist|sym|c4|d4|mirror|reflect|drift|lawler|fujita|strain|shear|segregation|rdf",
    ),
    (
        "Model Simulation and Theory",
        r"haldane|qi-wu|qiwuzhang|qwz|qi-hughes|qhz|model|simulation|simu|tbmodel|fesc|pdw|cdw|rcsj|p\(e\)|vortex|majorana|mzm|cdgm|chern|berry|ldos",
    ),
    (
        "General Utilities and Internal Helpers",
        r".*",
    ),
]

ROLE_ORDER = [
    "Panel callbacks and control handlers",
    "Interactive procedures and macros",
    "Windows, panels, and menus",
    "Computational and data helpers",
    "Internal/static helpers",
]

FEATURED_FUNCTIONS: list[tuple[str, str, str, str]] = [
    ("Daily wave/window shortcuts", "tpw", "Topmost Image Wave", "Returns the wave name from the topmost active image or subwindow, so KP commands can operate on the current graph without retyping wave names."),
    ("Daily wave/window shortcuts", "di", "Smart Image Display", "Displays a wave only when it is not already shown alone in a graph; otherwise it brings the existing graph forward. Use `di2()` for forced redisplay."),
    ("Daily wave/window shortcuts", "ed", "Smart Table Display", "Table counterpart of `di()`: opens a wave table intelligently and avoids duplicate table windows."),
    ("Daily wave/window shortcuts", "grabwin", "Find Window by Wave", "Returns the graph/window name containing a given wave, opening the display when needed."),
    ("Daily wave/window shortcuts", "grabwinnonew", "Find Window Without Opening", "Returns the containing window name without creating a new display, useful for non-invasive checks inside interactive workflows."),
    ("Daily wave/window shortcuts", "grabtable", "Find Table by Wave", "Finds the table containing a given wave, searching beyond the first graph element where `grabwin()` is not enough."),
    ("Daily wave/window shortcuts", "ckfig", "Prevent Duplicate Figures", "Call immediately after creating a complex graph to remove or reuse duplicate figure windows; `cklayout()` and `cktable()` provide the same pattern for layouts and tables."),
    ("Daily wave/window shortcuts", "wavelistsub", "Subwindow Wave List", "Returns wave names from subwindows while ignoring waves in the main window, useful for multi-panel graph management."),
    ("Smart display and 3D workflows", "d", "Compact 2D Displayer", "A one-command image displayer for 2D matrices with KP color controls and formatting hooks."),
    ("Smart display and 3D workflows", "d3d", "Smarter 3D Matrix Plotter", "Interactive 3D grid viewer with constant-Z image, integrated spectrum, FFT image, linecut extraction, Z normalization, and FFT-engineering integration."),
    ("Smart display and 3D workflows", "getall3dwave", "3D Wave Picker Helper", "Builds the 3D-wave list used by the `d3d()` prompt and related panel buttons."),
    ("Smart display and 3D workflows", "sumoned", "Average Z Spectrum", "Sums or averages a 3D grid along one dimension to obtain a representative 1D spectrum, skipping NaN curves in the updated workflow."),
    ("Smart display and 3D workflows", "Normalinecut", "Normalize Linecut", "Normalizes a 2D linecut along the x direction for cleaner waterfall and MDC/EDC-style display."),
    ("Smart display and 3D workflows", "Gridtolinecut", "Grid to Linecut", "Extracts all spectra from a 3D grid along a selected energy dimension and arranges them as a linecut-style dataset."),
    ("Fourier, filtering, and phase tools", "f", "Smart FFT", "Runs FFT on the first wave in the topmost graph, with handling for arbitrary point counts and NaN-containing data."),
    ("Fourier, filtering, and phase tools", "Const2dfilter", "Interactive 2D FFT Filter", "Opens the interactive FFT-filter controller for continuous tuning of the filter window and selected q vector."),
    ("Fourier, filtering, and phase tools", "extendffterealimage", "Expand Real-Image FFT", "Expands the half reciprocal-space FFT of a real image into an XY-symmetric image for PR-QPI and related visualization."),
    ("Fourier, filtering, and phase tools", "cyclecolorwave", "Cyclic Color Table", "Creates cyclic color waves with a selectable number of periods for phase/cycle visualizations."),
    ("Linecut, spectra, and matrix extraction", "sEDC", "Slice EDC Curves", "Slices a 2D matrix into EDC-style 1D waves for waterfall or spectral display."),
    ("Linecut, spectra, and matrix extraction", "sMDC", "Slice MDC Curves", "Slices a 2D matrix into MDC-style 1D waves for momentum/position-resolved inspection."),
    ("Linecut, spectra, and matrix extraction", "sum2dlinecut", "Integrate Linecut Dimension", "Integrates one dimension of a 2D linecut to produce a representative spectrum or profile."),
    ("Linecut, spectra, and matrix extraction", "diffeall", "Differentiate I/V Batch", "Calculates dI/dV curves from a batch of I/V curves and keeps the result organized for downstream display."),
    ("Linecut, spectra, and matrix extraction", "padm", "Pad 2D Matrix", "Pads a 2D matrix with zeros around the edge and enlarges the matrix dimensions for FFT/filter workflows."),
    ("Drift, strain, and correction workflows", "ConstLF", "Interactive LF Drift Correction", "Opens the Lawler-Fujita drift-correction controller after the required q-vector setup has been prepared."),
    ("Drift, strain, and correction workflows", "t2dlockin", "2D Lock-In Processing", "Runs the two-dimensional lock-in workflow sharing q-vector selection with FFT Engineering."),
    ("Drift, strain, and correction workflows", "shearall", "3D Shear Correction", "Applies shear correction to a 3D matrix using a corrected 2D reference wave, typically the matching topography."),
    ("Drift, strain, and correction workflows", "cal_strainbyshear", "Shear to Strain Estimate", "Calculates lattice mismatch/strain from a shear correction with an arbitrary angle between the lattice and shear axis."),
    ("Drift, strain, and correction workflows", "correct2Dmapc", "Gate-Leak Map Correction", "Shifts gate-dependent dI/dV curves individually and recombines them into a corrected 2D gate map."),
    ("Graph annotation and color helpers", "color3s_for3dm", "Subwindow Color Range", "Calculates a robust symmetric color range for a 3D-viewer subwindow image."),
    ("Graph annotation and color helpers", "Drawarrow", "Lattice Direction Arrows", "Draws x/y and a/b lattice-direction arrows on the active graph from an origin, angle, and length."),
]

SECTION_COLORS = [
    "#7c00d8",
    "#ff0000",
    "#fff200",
    "#0057d9",
    "#00b7eb",
    "#000000",
    "#b00000",
    "#00c853",
    "#caa4e8",
    "#8a2be2",
    "#eeeeee",
]

PARAM_HINT_RULES = [
    (r"^(ctrlName|ctrl)$", "Igor control name passed automatically by the panel callback."),
    (r"^varNum$", "Numeric value from an Igor SetVariable control."),
    (r"^varStr$", "String form of the SetVariable control value."),
    (r"^varName$", "Name of the Igor variable edited by the SetVariable control."),
    (r"^popNum$", "Selected popup-menu item index."),
    (r"^popStr$", "Selected popup-menu item text."),
    (r"^(name|namedata|matname|matt|mat)$", "Name or reference of the source wave/matrix being processed."),
    (r"(?:^|_)name$", "Wave, graph, or data object name used by this routine."),
    (r"path|folder", "File-system path or data-folder string used for loading or saving data."),
    (r"file", "File name or file-derived label used by the loader/export routine."),
    (r"grid", "Grid/map size, grid wave, or grid-data selector used by STM/STS workflows."),
    (r"topo", "Topography wave or topography-derived reference data."),
    (r"mat|matrix", "Matrix/2D wave input or matrix output name."),
    (r"wave|srcw|destw|wg|wi|w\d*$", "Igor wave reference used as input or output."),
    (r"start|stp|p1|q1|x1|y1", "Start point, index, or coordinate for the selected range."),
    (r"end|edp|p2|q2|x2|y2", "End point, index, or coordinate for the selected range."),
    (r"xmin|xmax|ymin|ymax|zmin|zmax|range", "Axis limit or numeric range boundary used for cropping, fitting, or display."),
    (r"delta|step|dE|dV", "Step size or energy/voltage increment used by the calculation."),
    (r"num|number|total|count|bins", "Number of spectra, waves, points, bins, or iterations to process."),
    (r"index|zn|layer", "Layer/index value selecting a slice of a 3D wave or energy stack."),
    (r"flag|mode|select|switch", "Mode flag controlling which branch of the workflow is used."),
    (r"factor|scale|ratio", "Scaling, normalization, interpolation, or correction factor."),
    (r"sigma|width|hwhm", "Width or sigma parameter for smoothing, fitting, or Fourier filtering."),
    (r"temp|tem|temperature", "Temperature parameter, usually in kelvin when used in spectral modeling."),
    (r"gap|deltaG|delta", "Gap/amplitude parameter used by superconducting or spectral fitting routines."),
    (r"theta|angle", "Angle parameter used for ARPES momentum conversion or rotation."),
    (r"kx|ky|kz|q|qp|qpi", "Momentum or Q-vector coordinate/index."),
]


def strip_igor_escapes(text: str) -> str:
    text = text.replace("\\r", " / ")
    text = re.sub(r"\\K\([^)]*\)", "", text)
    text = re.sub(r"\\F'[^']*'", "", text)
    text = re.sub(r"\\Z\d+", "", text)
    text = re.sub(r"\\?\$WMTEX\$|\\?\$/WMTEX\$|\\?/WMTEX\\?\$", "", text)
    text = re.sub(r"\\[BMS]\-?\d*", "", text)
    text = re.sub(r"\\JL", "", text)
    text = text.replace("\\", "")
    return text.strip()


def clean_comment(line: str) -> str:
    line = line.strip()
    line = re.sub(r"^/+", "", line)
    line = re.sub(r"^\*+", "", line)
    line = re.sub(r"[-=*_/]{3,}", " ", line)
    return line.strip(" \t/*")


def normalize_kind(kind: str) -> str:
    low = kind.lower()
    if low.startswith("function"):
        suffix = kind[len("function") :]
        return "Function" + suffix.upper()
    if low == "proc":
        return "Proc"
    if low == "window":
        return "Window"
    if low == "macro":
        return "Macro"
    if low == "menu":
        return "Menu"
    return kind


def display_kind(kind: str) -> str:
    normalized = normalize_kind(kind.strip())
    if normalized.lower() == "panel control":
        return "Panel Control"
    if normalized.lower() in {"button", "setvariable", "popupmenu", "checkbox", "slider", "tabcontrol"}:
        return normalized[0].upper() + normalized[1:]
    return normalized


def nearby_comment(lines: list[str], idx: int) -> str:
    comments: list[str] = []
    j = idx - 1
    while j >= 0 and len(comments) < 4:
        s = lines[j].strip()
        if not s:
            if comments:
                break
            j -= 1
            continue
        if s.startswith("//") or s.startswith("////") or s.startswith("**"):
            c = clean_comment(s)
            if c:
                comments.append(c)
            j -= 1
            continue
        break
    comments.reverse()
    text = " ".join(comments)
    text = re.sub(r"\s+", " ", text)
    return text[:260]


def signature_args(signature: str) -> list[str]:
    start = signature.find("(")
    end = signature.find(")", start + 1)
    if start < 0 or end < 0 or end <= start + 1:
        return []
    raw = signature[start + 1 : end]
    args: list[str] = []
    for part in raw.split(","):
        token = part.strip()
        if not token:
            continue
        token = token.split("//", 1)[0].strip()
        token = token.split("=", 1)[0].strip()
        token = token.replace("&", "").strip()
        if token:
            args.append(token)
    return args


def clean_note_text(text: str) -> str:
    text = strip_igor_escapes(text)
    text = text.replace("\t", " ")
    text = re.sub(r"\s+", " ", text)
    text = re.sub(r"\s+([,.;:])", r"\1", text)
    return text.strip()


def strip_strings_and_comments(line: str) -> str:
    out: list[str] = []
    in_string = False
    i = 0
    while i < len(line):
        ch = line[i]
        if not in_string and ch == "/" and i + 1 < len(line) and line[i + 1] == "/":
            break
        if ch == '"':
            in_string = not in_string
            out.append(" ")
            i += 1
            continue
        if in_string:
            out.append(" ")
        else:
            out.append(ch)
        i += 1
    return "".join(out)


def collect_prompts(body: list[str]) -> list[str]:
    prompts: list[str] = []
    for key, label in collect_prompt_map(body).items():
        item = f"{key} = {label}"
        if item not in prompts:
            prompts.append(item)
    return prompts[:6]


def collect_prompt_map(body: list[str]) -> dict[str, str]:
    prompts: dict[str, str] = {}
    for line in body:
        m = PROMPT_RE.match(line)
        if not m:
            continue
        prompts[m.group(1)] = clean_note_text(m.group(2))
    return prompts


def collect_declaration_notes(body: list[str]) -> dict[str, str]:
    notes: dict[str, str] = {}
    for line in body[:80]:
        m = DECL_RE.match(line)
        if not m:
            continue
        comment = clean_note_text(m.group("comment") or "")
        names = re.split(r",", m.group("names"))
        for raw in names:
            name = raw.strip().split("=", 1)[0].strip()
            name = re.sub(r"\[.*\]", "", name).strip()
            if not name or not re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", name):
                continue
            if comment and name not in notes:
                notes[name] = comment
    return notes


def collect_assignment_notes(body: list[str], args: list[str]) -> dict[str, str]:
    arg_set = {a.lower(): a for a in args}
    notes: dict[str, str] = {}
    for line in body[:120]:
        if "//" not in line:
            continue
        code, comment = line.split("//", 1)
        m = ASSIGN_RE.match(code)
        if not m:
            continue
        name = m.group("name")
        if name.lower() in arg_set:
            notes[arg_set[name.lower()]] = clean_note_text(comment)
    return notes


def collect_param_usage(body: list[str], arg: str) -> list[str]:
    hits: list[str] = []
    arg_re = re.compile(rf"\b{re.escape(arg)}\b", re.IGNORECASE)
    for line in body[:160]:
        stripped = clean_note_text(line)
        if not stripped or stripped.lower().startswith(("variable ", "string ", "wave ", "nvar ", "svar ")):
            continue
        if arg_re.search(strip_strings_and_comments(line)):
            if any(token in line for token in ("SetScale", "Duplicate", "Make", "Display", "AppendImage", "CurveFit", "FuncFit", "MatrixOP", "LoadWave", "Save", "ImageStats", "WaveStats")):
                hits.append(stripped[:140])
        if len(hits) >= 2:
            break
    return hits


def infer_param_note(arg: str, *, entry_name: str, file: str, body: list[str], prompt_map: dict[str, str], decl_notes: dict[str, str], assign_notes: dict[str, str]) -> str:
    if arg in prompt_map:
        return prompt_map[arg]
    if arg in decl_notes:
        return decl_notes[arg]
    if arg in assign_notes:
        return assign_notes[arg]

    low = arg.lower()
    context = " ".join([entry_name, file, "\n".join(body[:60])]).lower()
    for pattern, note in PARAM_HINT_RULES:
        if re.search(pattern, low, re.IGNORECASE):
            if re.search(r"nanonis|3ds|sxm|nsp|sts|grid", context) and "wave" in note:
                return note + " In this context it usually refers to STM/STS or Nanonis-derived data."
            if re.search(r"fft|qpi|fourier|phase", context) and re.search(r"index|coordinate|range|wave|matrix", note, re.IGNORECASE):
                return note + " In this context it is used for Fourier/QPI or phase-map processing."
            return note

    usage = collect_param_usage(body, arg)
    if usage:
        return "Used in: " + " / ".join(usage)

    cls, typ = param_css_class(arg)
    if typ == "wave":
        return "Igor wave or matrix input consumed by the calculation."
    if typ == "string":
        return "String name used to locate an Igor wave, graph, folder, or output object."
    if typ == "datafolder":
        return "Igor data-folder reference or path used for output/input routing."
    return "Numeric parameter controlling the calculation branch, index, range, scale, or model value."


def build_param_docs(entry_name: str, file: str, body: list[str], args: list[str]) -> dict[str, str]:
    prompt_map = collect_prompt_map(body)
    decl_notes = collect_declaration_notes(body)
    assign_notes = collect_assignment_notes(body, args)
    return {
        arg: infer_param_note(
            arg,
            entry_name=entry_name,
            file=file,
            body=body,
            prompt_map=prompt_map,
            decl_notes=decl_notes,
            assign_notes=assign_notes,
        )
        for arg in args
    }


def collect_execute(body: list[str]) -> str:
    for line in body[:12]:
        m = EXECUTE_RE.search(line)
        if m:
            return m.group("command")
    return ""


def collect_calls(name: str, body: list[str]) -> list[str]:
    calls: list[str] = []
    for line in body:
        s = strip_strings_and_comments(line)
        if ENTRY_RE.match(s):
            continue
        for m in CALL_RE.finditer(s):
            call = m.group(1)
            low = call.lower()
            if call == name or low in CALL_EXCLUDE:
                continue
            if low in {"if", "for", "while", "do", "switch", "case", "return", "function", "proc", "static"}:
                continue
            if call not in calls:
                calls.append(call)
    return calls[:8]


def infer_domain(file: str, name: str, body: list[str]) -> str:
    haystack = " ".join([file, name, "\n".join(body[:40])]).lower()
    hits: list[str] = []
    for pattern, phrase in DOMAIN_RULES:
        if re.search(pattern, haystack):
            hits.append(phrase)
    return "; ".join(hits[:3])


def infer_operations(body: list[str]) -> list[str]:
    text = "\n".join(line.split("//", 1)[0] for line in body)
    ops: list[str] = []
    for pattern, phrase in IGOR_COMMAND_PATTERNS:
        if re.search(pattern, text, re.IGNORECASE):
            ops.append(phrase)
    return ops[:5]


def function_role(kind: str, name: str, controls: list[dict], static: bool) -> str:
    low = name.lower()
    if name.startswith("ButtonProc_"):
        return "Panel button callback"
    if name.startswith("SetVarProc_"):
        return "Panel set-variable callback"
    if name.startswith("PopMenuProc_"):
        return "Panel popup-menu callback"
    if kind == "Window":
        return "Igor window/panel recreation routine"
    if kind == "Menu":
        return "Igor menu definition"
    if kind == "Macro":
        return "Igor macro entry point"
    if kind == "Proc":
        return "Interactive Igor procedure"
    if static:
        return "Internal helper function"
    if "/wave" in kind.lower():
        return "Wave-returning helper"
    if "/s" in kind.lower():
        return "String-returning helper"
    if low.startswith(("fit", "calc", "make", "create", "load", "save", "get", "set")):
        return "Utility function"
    if controls:
        return "Panel callback/helper"
    return "Function"


def infer_name_action(name: str) -> str:
    low = name.lower()
    low = re.sub(r"^(buttonproc_|setvarproc_|popmenuproc_)", "", low)
    specials = [
        ("setwavenameinproctext", "Purpose: rewrites wave names inside stored graph recreation/procedure text."),
        ("removesinglequote", "Purpose: removes quote characters from a stored graph command string before execution."),
        ("rebuildappendcmd", "Purpose: rebuilds Igor append commands so saved graph traces point to the current waves."),
        ("savegraph", "Purpose: captures a graph recreation command so the graph can be rebuilt later."),
        ("loadgraph", "Purpose: rebuilds a saved graph from stored recreation/procedure text."),
        ("kp_loadnanonis3ds", "Purpose: parses a Nanonis 3ds spectroscopy/grid file and returns loaded waves."),
        ("kp_loadnanonissxmnsp", "Purpose: parses Nanonis sxm/nsp topography-style files and returns loaded waves."),
        ("kp_loadnanonisfolder", "Purpose: walks a folder and loads supported Nanonis files through the KP-local loader."),
        ("kp_recordloadedfile", "Purpose: records loaded file names in `root:File_Name` for downstream KP workflows."),
        ("kp_getlastloadednanonisfolder", "Purpose: returns the most recently created KP Nanonis data folder."),
        ("kp_nanoniscleanup", "Purpose: cleanup hook replacing the old KM exit call; KP's local loader has no external package to unload."),
    ]
    for token, phrase in specials:
        if token in low:
            return phrase
    rules = [
        (r"^load|autoload", "Purpose: loads data or launches an automatic loading workflow."),
        (r"^save|export|wave2file|file2wave", "Purpose: saves, exports, or converts data between files and Igor waves."),
        (r"^make|^create|^build|^generate", "Purpose: creates new waves, maps, figures, or simulation data."),
        (r"^get|extract|reader|read", "Purpose: extracts values, metadata, cursor information, or derived waves."),
        (r"^set|control|update", "Purpose: updates parameters, controls, scales, or display state."),
        (r"fit|gauss|gcb|dyne|bcs|peak", "Purpose: fits or extracts spectral/peak parameters."),
        (r"plot|display|append|di\d*", "Purpose: displays waves, images, contours, or graph overlays."),
        (r"fft|filter|phase|lockin", "Purpose: performs Fourier, filtering, phase, or lock-in processing."),
        (r"sym|mirror|reflect", "Purpose: applies symmetry, mirror, or reflection operations."),
        (r"interp|rescale|scale|resize|pad", "Purpose: resamples, rescales, pads, or changes wave dimensions."),
        (r"rot|rotate|shear|drift|strain", "Purpose: applies geometric correction or extracts deformation/strain information."),
        (r"smooth|norm|bkg|background|trend", "Purpose: smooths, normalizes, or removes background/trend components."),
        (r"kill|clean|delete|remove|rmv", "Purpose: removes waves/windows/data points or cleans intermediate state."),
        (r"copy|duplicate|rename", "Purpose: copies, duplicates, or renames Igor waves/traces."),
        (r"link|combine|sum|average|ave", "Purpose: combines many waves/slices into a map, linecut, or averaged output."),
        (r"haldane|qiwuzhang|qwz|qhz|hughes|tbmodel|fesc", "Purpose: runs a model/simulation workflow and produces calculated spectra, bands, or maps."),
    ]
    for pattern, phrase in rules:
        if re.search(pattern, low):
            return phrase
    return ""


def infer_description(
    *,
    file: str,
    kind: str,
    name: str,
    signature: str,
    comment: str,
    body: list[str],
    controls: list[dict],
    static: bool,
) -> tuple[str, str]:
    args = signature_args(signature)
    prompts = collect_prompts(body)
    execute = collect_execute(body)
    calls = collect_calls(name, body)
    domain = infer_domain(file, name, body)
    ops = infer_operations(body)
    role = function_role(kind, name, controls, static)

    parts: list[str] = []
    source = "inferred"
    if comment:
        parts.append(clean_note_text(comment))
        source = "inline+inferred"
    else:
        if domain:
            parts.append(f"{role} for {domain}.")
        else:
            parts.append(f"{role} in `{file}`.")

    action = infer_name_action(name)
    if action:
        parts.append(action)

    if controls:
        titles = [clean_note_text(c["title"] or c["control"]) for c in controls]
        titles = [t for t in dict.fromkeys(titles) if t]
        if titles:
            parts.append("Panel control(s): " + ", ".join(f"`{t}`" for t in titles[:6]) + ".")

    if kind == "Menu":
        parts.append("Usage: defines Igor menu entries; users normally access it from the Igor menu bar.")
    elif kind == "Window":
        parts.append(f"Usage: call `{name}()` to recreate or bring up the Igor window/panel.")
    elif execute:
        parts.append(f"Usage: triggered as a wrapper that opens/runs `{execute}()`.")
    elif kind in {"Proc", "Macro"}:
        if args:
            parts.append("Usage: run from Igor with parameters " + ", ".join(f"`{a}`" for a in args[:8]) + ".")
        else:
            parts.append("Usage: run interactively from Igor or from a panel callback.")
    elif name.startswith(("ButtonProc_", "SetVarProc_", "PopMenuProc_")):
        parts.append("Usage: called automatically by Igor when the linked panel control changes.")
    elif args:
        parts.append("Usage: call as `" + name + "(" + ", ".join(args[:8]) + ")`.")
    else:
        parts.append(f"Usage: call `{name}()` from Igor procedure code or the command line.")

    if prompts:
        parts.append("Dialog prompts: " + "; ".join(prompts) + ".")

    if ops:
        parts.append("Code behavior: " + "; ".join(ops) + ".")

    if calls:
        parts.append("Main internal calls: " + ", ".join(f"`{c}()`" for c in calls[:6]) + ".")

    description = " ".join(p for p in parts if p)
    description = re.sub(r"\s+", " ", description).strip()
    return description[:900], source


def infer_category(entry: dict) -> str:
    control_text = " ".join(c.get("title") or c.get("control", "") for c in entry.get("controls", []))
    haystack = " ".join(
        [
            entry.get("name", ""),
            entry.get("file", ""),
            entry.get("kind", ""),
            entry.get("signature", ""),
            entry.get("execute", ""),
            control_text,
        ]
    ).lower()
    best = "General Utilities and Internal Helpers"
    best_score = 0
    for order, (category, pattern) in enumerate(CATEGORY_RULES):
        if category == "General Utilities and Internal Helpers":
            continue
        score = len(re.findall(pattern, haystack, re.IGNORECASE))
        if score > best_score:
            best = category
            best_score = score
    return best


def infer_role_group(entry: dict) -> str:
    name = entry["name"]
    kind = entry["kind"]
    if name.startswith(("ButtonProc_", "SetVarProc_", "PopMenuProc_")) or entry.get("controls"):
        return "Panel callbacks and control handlers"
    if kind in {"Proc", "Macro"}:
        return "Interactive procedures and macros"
    if kind in {"Window", "Menu"}:
        return "Windows, panels, and menus"
    if entry.get("static"):
        return "Internal/static helpers"
    return "Computational and data helpers"


def is_control_entry(entry: dict) -> bool:
    return entry.get("role_group") == "Panel callbacks and control handlers" or entry.get("name", "").startswith(
        ("ButtonProc_", "SetVarProc_", "PopMenuProc_")
    )


def read_files() -> dict[str, list[str]]:
    return {p.name: p.read_text(errors="replace").splitlines() for p in sorted(SRC.glob("*.ipf"))}


def parse_control_lines(files: dict[str, list[str]]) -> list[dict]:
    controls: list[dict] = []
    latest: dict[tuple[str, str, str], dict] = {}
    for file, lines in files.items():
        current_window = ""
        for i, line in enumerate(lines, 1):
            wm = WINDOW_START_RE.match(line)
            if wm:
                current_window = wm.group("name")
            m = CONTROL_LINE_RE.match(line)
            if not m:
                continue
            kind = m.group("kind")
            name = m.group("name")
            key = (file, current_window, name)
            rec = latest.get(key)
            if rec is None or ("proc=" in line and rec.get("proc") and i - rec["line"] > 3):
                rec = {
                    "file": file,
                    "line": i,
                    "window": current_window,
                    "control": name,
                    "control_kind": kind,
                    "title": "",
                    "proc": "",
                    "x": None,
                    "y": None,
                    "w": None,
                    "h": None,
                    "disable": None,
                }
                latest[key] = rec
                controls.append(rec)
            attrs = m.group("attrs")
            title = ""
            tm = TITLE_RE.search(attrs)
            if tm:
                title = strip_igor_escapes(tm.group("title"))
            if title:
                rec["title"] = clean_note_text(title)
            pm = PROC_RE.search(attrs)
            if pm:
                rec["proc"] = pm.group("proc")
            posm = POS_RE.search(attrs)
            if posm:
                rec["x"] = float(posm.group("x"))
                rec["y"] = float(posm.group("y"))
            sizem = SIZE_RE.search(attrs)
            if sizem:
                rec["w"] = float(sizem.group("w"))
                rec["h"] = float(sizem.group("h"))
            dism = DISABLE_RE.search(attrs)
            if dism:
                rec["disable"] = int(dism.group("disable"))
    return [c for c in controls if c.get("proc") or c.get("title")]


def collect_controls(files: dict[str, list[str]]) -> dict[str, list[dict]]:
    controls: dict[str, list[dict]] = defaultdict(list)
    for rec in parse_control_lines(files):
        if rec.get("proc"):
            controls[rec["proc"]].append(rec)
    return controls


def collect_entries(files: dict[str, list[str]], controls: dict[str, list[dict]]) -> list[dict]:
    entries: list[dict] = []
    for file, lines in files.items():
        positions: list[tuple[int, re.Match[str]]] = []
        for idx, line in enumerate(lines):
            m = ENTRY_RE.match(line)
            if m:
                positions.append((idx, m))
        for pos, (idx, m) in enumerate(positions):
            next_idx = positions[pos + 1][0] if pos + 1 < len(positions) else len(lines)
            kind = normalize_kind(m.group("kind"))
            name = m.group("name").strip('"')
            signature = lines[idx].strip()
            comment = nearby_comment(lines, idx)
            linked_controls = controls.get(name, [])
            body = lines[idx + 1 : next_idx]
            args = signature_args(signature)
            description, description_source = infer_description(
                file=file,
                kind=kind,
                name=name,
                signature=signature,
                comment=comment,
                body=body,
                controls=linked_controls,
                static=bool(m.group("static")),
            )
            entry = {
                "file": file,
                "line": idx + 1,
                "kind": kind,
                "name": name,
                "signature": signature,
                "description": description,
                "execute": collect_execute(body),
                "controls": linked_controls,
                "static": bool(m.group("static")),
                "description_source": description_source,
                "param_docs": build_param_docs(name, file, body, args),
            }
            entry["category"] = infer_category(entry)
            entry["role_group"] = infer_role_group(entry)
            entry["is_control_entry"] = is_control_entry(entry)
            entries.append(entry)
    enrich_entries_from_update_log(entries)
    return entries


DATE_LINE_RE = re.compile(r"^\s*\d{2}/\d{2}(?:[-_/]\d{2})?/\d{4}|\bVer\.\s*\d+", re.IGNORECASE)
LOG_FUNCTION_RE = re.compile(r"\b([A-Za-z_][A-Za-z0-9_]*)\s*\(")
CURATED_UPDATE_LOG_NOTES: dict[str, list[str]] = {
    "d3d": [
        '2023-08-17: Added the smarter 3D matrix plotter. Launch it with `d3d("name", zn)`, where `zn` is the energy dimension, usually 2. The viewer shows a constant-energy image, an integrated f(Z) trace, and an FFT image; changing Z updates the image and FFT, the Linecut button opens horizontal/vertical/arbitrary linecut tools, and optional Z normalization keeps a reversible `Raw_name` copy.',
        "2023-08-17: The viewer can feed FFT engineering: activate the constant-Z image, click Launch in the FFT Engineer section, then tune the Z plane while using 2D lock-in or FFT-filter workflows. MDC slicing can convert selected linecuts into waterfall traces for Z_color display.",
        "2023-10-17: Added vertical linecut support through the Linecut button.",
    ],
    "manualvalue_1dextrac": [
        '2024-06-27: Added manual correction for MultiPeak 1D extraction. Use `manualvalue_1Dextrac(leftvalue, rightvalue)` from the command line or panel button; each argument is a semicolon-separated list. A blank value writes NaN for a missing peak, `0` leaves the existing peak unchanged, and the entries are ordered by increasing absolute peak energy.',
    ],
    "dynes": [
        '2024-05-12: Added the Dynes superconducting density-of-states function. Example: `make/n=100/o test; setscale/I x,-5,5,"",test; test=DyneS(x,1,0.1)`.',
    ],
    "correct2dmapc": [
        '2023-08-09: Added the gate-map leakage corrector behind the "Fix gate leak" button. It shifts spectra measured at different gate voltages according to a zero-bias reference wave and recombines them into a corrected 2D matrix.',
    ],
    "cnfyj": [
        "2023-07-16: Improved the Lawler-Fujita phase-jump remover for images with multiple phase jumps. This version is better than the earlier JumpRemover, but if the image contains missing jumps or phase vortices, manual cleanup with the older remover may still be needed.",
    ],
    "correctboundphmap": [
        '2023-11-09: Corrects boundary artifacts in moving-window phase-difference maps. It removes artificial phase differences that appear when the moving window crosses a lattice phase jump, and is connected to the "FixBnd" button.',
    ],
    "shearall": [
        '2023-09-12: Applies shear correction to every layer of a 3D matrix through the "Go3D" workflow. First correct the corresponding 2D reference image, usually the topography, then pass that reference to `shearall(mat3dn, refwave, factor)`. The routine assumes the energy dimension is index 2.',
    ],
    "constlf": [
        '2023-07-20: Interactive Lawler-Fujita tuning panel. Run the single-value LF workflow first, then use the "adj" control to continuously tune the LF correction parameters.',
    ],
    "continitialshearfit": [
        '2023-07-20: Interactive shear-correction fitting panel. Run the initial single-value shear workflow first, then use "adj" to refine the shear coefficients.',
    ],
    "ftlinecutc": [
        "2023-09-13: FFT filter for linecuts along the Y direction. It does not require the FFT Engineer Launch step; enter the q value manually, then tune the Gaussian cutoff and q interactively.",
    ],
    "ftclp": [
        "2023-10-12: Low-pass FFT filter for 2D waves. The even-dimension requirement was removed so the filter can be applied to matrices with odd dimensions.",
    ],
    "lf": [
        "2023-07-13: Lawler-Fujita drift correction using the same Launch/GetA/GetB workflow as the FFT filter. Later FFT Engineering updates use Q_A and Q_B from the interpolated FFT image and support marquee-based fitting limits.",
    ],
    "t2dlockin": [
        "2023-08-12: Added 2D lock-in processing. The workflow shares Q-vector selection with FFT Engineering and can be used together with filtering and LF correction.",
    ],
    "determineqbyphasec": [
        '2024-05-09: Refines Q by calculating the median phase-gradient map while changing the Q position. After clicking "Refine Q", users can inspect the gradient map, refine manually, or fit the center by 2D Gaussian and save the result to Qa/Qb.',
    ],
    "determineqbyphase": [
        '2024-05-09: Backend calculation for Refine Q. It evaluates the phase-gradient response for a trial Q and supports saving the refined Q to Qa/Qb.',
    ],
    "color3s_for3dmprqpi": [
        "2023-12-03: Returns a symmetric sigma range for PR-QPI diverging color scales; it is intended for use in `ModifyImage ... ctab={-sigma, sigma, ...}`.",
    ],
    "extendffterealimage": [
        "2023-12-03: Expands the half reciprocal-space FFT of a real image into an XY-symmetric full image for PR-QPI and related visualization.",
    ],
    "extendffterealimage_c": [
        "2023-12-03: Complex-wave variant of `extendffterealimage`, used when the FFT data are kept in complex form.",
    ],
    "c4sym_prqpi": [
        "2023-12-03: Applies fourfold symmetrization to a PR-QPI wave before display or further analysis.",
    ],
    "gridtolinecut": [
        "2025-05-19: Extracts all dI/dV spectra from a 3D grid wave and organizes them as a linecut for downstream plotting or analysis.",
    ],
    "diffeall": [
        "2025-05-19: Differentiates a batch of I(V) curves to calculate dI/dV curves.",
    ],
    "scalewave": [
        "2025-05-19: Rescales a dI/dV curve using a voltage-divider correction factor.",
    ],
    "calculates": [
        "2025-05-19: Calculates the divider-correction factor needed to align a measured feature from `Pvalue` to the target value `xshouldbe`.",
    ],
    "rescalegroup": [
        "2025-05-19: Builds a corrected linecut by applying individual voltage-divider correction ratios to a batch of dI/dV curves.",
    ],
    "madewavebytemplate2": [
        "2025-05-19: Reformats a wave so that its dimensions and scaling follow a reference/template wave.",
    ],
    "unevenlinep": [
        "2025-05-19: Builds a linecut from a batch of delta waves with uneven dimensions by using a template wave as the reference geometry.",
    ],
    "createtriangularlatticecoordinates": [
        "2024-11-23: Calculates honeycomb/triangular lattice coordinates from the origin, lattice constant, and rotation angle; used by the TBG/TTG and lattice-simulation tools.",
    ],
    "fitimagehoneycombc": [
        "2024-11-25: Appends or fits a honeycomb lattice overlay on an image using lattice constant, rotation angle, and xy offset parameters.",
    ],
    "fitimagetriangularc": [
        "2024-11-25: Appends or fits a triangular lattice overlay on an image using lattice constant, rotation angle, and xy offset parameters.",
    ],
    "fitimagesquarec": [
        "2024-11-25: Appends or fits a square lattice overlay on an image using lattice constant, rotation angle, and xy offset parameters.",
    ],
    "rcsjc": [
        "2025-05-22: Opens the RCSJ model simulator for supercurrent dynamics, including IV hysteresis and voltage-versus-time traces controlled by temperature, damping, smoothing, and current.",
    ],
    "calculatep0ec": [
        "2025-06-08: Opens the P(E)-theory simulation panel for environmental tunneling calculations and dynamic Coulomb blockade examples.",
    ],
    "f": [
        "2023-07-10: Performs a smart FFT on the first wave in the topmost graph; the workflow was later updated to handle arbitrary point counts and NaN-containing data.",
    ],
    "getall3dwave": [
        "2023-08-17: Provides the 3D-wave list used by the smarter 3D matrix plotter prompt, so users can select a root-level 3D wave before launching `d3d`.",
    ],
    "curvature": [
        "2021-09-17: Signal-enhancement routine based on Peng Zhang's curvature-analysis method for highlighting dispersive features.",
    ],
    "cyclecolorwave": [
        "2024-01-29: Creates cyclic color waves with an arbitrary number of periods; `c` is the number of cycles and `index` selects the base color-table entry.",
    ],
    "drawarrow": [
        "2024-05-03: Draws x/y and a/b lattice-direction arrows on the active graph from an origin, angle, and length.",
    ],
    "cal_strainbyshear": [
        "2024-01-24: Calculates lattice mismatch after shear correction for a lattice at an arbitrary angle relative to the shear axis; connected to the epsilon button in the strain workflow.",
    ],
    "buttonproc_sizemapauto": [
        "2023-08-12: Formats a topography automatically with a color bar and scale bar.",
    ],
    "buttonproc_zcoloro": [
        "2023-08-11: Opens the smart Z_color waterfall display from the Adjust-on-Graph section.",
    ],
    "ckfig_child": [
        "2023-08-25: Checks whether a multi-subwindow graph already exists, mirroring the `ckfig` duplicate-window pattern for child-window displays.",
    ],
    "t2nddpeak": [
        "2023-09-21: MultiPeak extraction for 1D or 2D waves; the upgraded layout can show an arbitrary number of extracted peak figures and includes cleanup controls.",
    ],
}


def update_log_date_for(lines: list[str], index: int) -> str:
    for j in range(index, -1, -1):
        line = lines[j].strip()
        if not line:
            continue
        if DATE_LINE_RE.search(line):
            dm = re.search(r"\d{2}/\d{2}(?:[-_/]\d{2})?/\d{4}", line)
            return dm.group(0) if dm else line.split("Ver.", 1)[0].strip()
    return ""


def update_log_context(lines: list[str], index: int, mentioned: set[str], entry_names: set[str]) -> str:
    selected = [lines[index].strip()]
    for j in range(index + 1, min(len(lines), index + 4)):
        raw_next = lines[j]
        nxt = raw_next.strip()
        if not nxt:
            break
        if DATE_LINE_RE.search(nxt):
            break
        next_names = {m.group(1).lower() for m in LOG_FUNCTION_RE.finditer(nxt) if m.group(1).lower() in entry_names}
        if next_names and not next_names.issubset(mentioned):
            break
        selected.append(nxt)
        if len(" ".join(selected)) > 520:
            break
    return " ".join(selected)


def clean_update_log_note(text: str) -> str:
    replacements = {
        "Chang ": "Changed ",
        "caculate": "calculate",
        "Caculate": "Calculate",
        "martrix": "matrix",
        "Typograph": "topography",
        "Botton": "button",
        "continues": "continuously",
        "covert": "convert",
        "pervious": "previous",
        "sam work flow": "same workflow",
        "no long requires": "no longer requires",
        "awared": "aware",
        "choice": "choose",
        "lauch": "launch",
        "lauching": "launching",
        "enginnering": "engineering",
        "gatemapm": "gate map",
        "Multipack": "MultiPeak",
        "wavefucntion": "wavefunction",
        "works very good": "works well",
        "multiple times phase jump": "multiple phase jumps",
        "two image": "two images",
        "a artifact": "an artifact",
        "the moving window cross": "the moving window crosses",
        "can not": "cannot",
        "non-Nan": "non-NaN",
        "nan": "NaN",
        "Nan": "NaN",
        "dimsize": "dimension size",
    }
    text = text.replace("“", '"').replace("”", '"').replace("’", "'").replace("—>", "->")
    text = re.sub(r"\s+", " ", text).strip(" \t.;")
    for old, new in replacements.items():
        text = text.replace(old, new)
    text = re.sub(r"\bNew Function\b", "new function", text)
    text = re.sub(r"\bFunction\s+([A-Za-z_][A-Za-z0-9_]*\()", r"\1", text)
    text = re.sub(r"\bProc\s+([A-Za-z_][A-Za-z0-9_]*\()", r"\1", text)
    text = re.sub(r"\bNew button was added\b", "a new button was added", text, flags=re.IGNORECASE)
    text = re.sub(r"\bNew Botton\b", "new button", text, flags=re.IGNORECASE)
    text = re.sub(r"\bthe FFT of real image only have\b", "the FFT of a real image contains", text, flags=re.IGNORECASE)
    text = re.sub(r"\bwhich is for\b", "for", text)
    text = re.sub(r"\bcan do\b", "can perform", text)
    text = re.sub(r"\bcan calculate\b", "calculates", text)
    text = re.sub(r"\byou can\b", "users can", text, flags=re.IGNORECASE)
    text = re.sub(r"\byou need\b", "users should", text, flags=re.IGNORECASE)
    text = re.sub(r"\bBefore start\b", "Before starting", text)
    text = re.sub(r"\bby click\b", "by clicking", text)
    text = re.sub(r"\bclick \"([^\"]+)\"", r'click the "\1" button', text)
    text = re.sub(r"\busers should to\b", "users should", text)
    text = re.sub(r"\btry use\b", "try using", text)
    return text[:700].rstrip(" ,;") + "."


def build_update_log_notes(entry_names: set[str]) -> dict[str, list[str]]:
    if not UPDATE_LOG.exists():
        return {}
    lines = UPDATE_LOG.read_text(errors="replace").splitlines()
    notes: dict[str, list[str]] = defaultdict(list)
    for i, line in enumerate(lines):
        if "The Kong Panel (KP) is" in line or "All copyright is reserved" in line:
            continue
        mentioned = []
        for m in LOG_FUNCTION_RE.finditer(line):
            key = m.group(1).lower()
            if key in entry_names:
                mentioned.append(key)
        if not mentioned:
            continue
        date_text = update_log_date_for(lines, i)
        context = clean_update_log_note(update_log_context(lines, i, set(mentioned), entry_names))
        if date_text:
            context = f"{date_text}: {context}"
        for key in dict.fromkeys(mentioned):
            if context not in notes[key]:
                notes[key].append(context)
    for key, curated in CURATED_UPDATE_LOG_NOTES.items():
        if key in entry_names:
            notes[key] = curated
    return notes


def looks_like_usage_note(note: str) -> bool:
    low = note.lower()
    return any(
        token in low
        for token in [
            "users can",
            "users should",
            "for example",
            "command line",
            "before starting",
            "by clicking",
            "click the",
            "button",
            "prompt",
            "launch",
        ]
    )


def enrich_entries_from_update_log(entries: list[dict]) -> None:
    entry_names = {e["name"].lower() for e in entries}
    notes = build_update_log_notes(entry_names)
    if not notes:
        return
    for entry in entries:
        log_notes = notes.get(entry["name"].lower(), [])
        if not log_notes:
            continue
        chosen = log_notes[:3]
        usage_notes = [n for n in chosen if looks_like_usage_note(n)]
        detail_notes = [n for n in chosen if n not in usage_notes]
        additions: list[str] = []
        if usage_notes:
            additions.append("Usage: Update-log guidance - " + " ".join(usage_notes[:2]))
        if detail_notes:
            additions.append("Update log: " + " ".join(detail_notes[:2]))
        entry["description"] = re.sub(
            r"\s+",
            " ",
            (entry["description"].rstrip() + " " + " ".join(additions)).strip(),
        )[:1600]
        if entry.get("description_source") == "inferred":
            entry["description_source"] = "inferred+update-log"


def css() -> str:
    return """
:root {
  color-scheme: light;
  --bg: #f4f6f8;
  --paper: #ffffff;
  --ink: #17191d;
  --muted: #68707a;
  --line: #d8dde6;
  --link: #0b5cad;
  --keyword: #2f65d9;
  --name: #111111;
  --string: #16824a;
  --variable: #b65f13;
  --wave: #0b62aa;
  --datafolder: #9a3bb4;
  --optional: #777777;
  --panel: #6f3cc3;
  --procedure: #9f2f2c;
  --window: #996600;
  --helper: #0057d9;
  --accent: #b88746;
  --sidebar-bg: #fbfaf7;
  --soft: #f8fafc;
  --shadow: 0 14px 34px rgba(23, 25, 29, .08);
  --shadow-small: 0 4px 12px rgba(23, 25, 29, .06);
  --sidebar-width: 26.4em;
}
body {
  margin: 0;
  background: var(--bg);
  color: var(--ink);
  font: 15px/1.55 -apple-system, BlinkMacSystemFont, "Avenir Next", "Gill Sans MT", "Gill Sans", "Trebuchet MS", Arial, sans-serif;
}
header {
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  width: var(--sidebar-width);
  box-sizing: border-box;
  padding: 14px 12px 76px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  background: var(--sidebar-bg);
  border-right: 1px solid var(--line);
  box-shadow: 8px 0 28px rgba(23, 25, 29, .07);
}
h1 {
  margin: 0 0 7px;
  font: 700 16.5pt/1.1 "Avenir Next", "Gill Sans MT", "Gill Sans", Arial, sans-serif;
  letter-spacing: 0;
}
h2 {
  margin: 2.35em 0 .95em;
  padding-bottom: .36em;
  font: 700 20pt/1.15 "Avenir Next", "Gill Sans MT", "Gill Sans", Arial, sans-serif;
  border-bottom: 1px solid var(--line);
}
h3 { margin: 1.8em 0 .72em; font-size: 14pt; color: var(--procedure); }
.wrap { margin-left: calc(var(--sidebar-width) + 1.4em); padding: 26px 34px 76px; max-width: 1220px; }
.sidebar-resizer {
  position: fixed;
  top: 0;
  bottom: 0;
  left: var(--sidebar-width);
  width: 8px;
  cursor: col-resize;
  z-index: 10;
}
.sidebar-resizer::after {
  content: "";
  display: block;
  width: 1px;
  height: 100%;
  margin-left: 3px;
  background: transparent;
}
.sidebar-resizer:hover::after { background: #999999; }
.toolbar {
  display: flex;
  flex-wrap: nowrap;
  gap: 5px;
  margin: 10px 0 8px;
}
.tool-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  box-sizing: border-box;
  flex: 1 1 0;
  min-width: 0;
  min-height: 28px;
  border: 1px solid #18202b;
  border-radius: 7px;
  background: #18202b;
  color: #ffffff;
  padding: 5px 7px;
  text-align: center;
  font: 700 8.7pt "Gill Sans MT", "Gill Sans", "Trebuchet MS", Arial, sans-serif;
  white-space: nowrap;
  cursor: pointer;
  text-decoration: none;
  box-shadow: var(--shadow-small);
}
.tool-button:hover {
  background: #0f141c;
  border-color: #0f141c;
  text-decoration: none;
}
.control-hidden .entry.control-entry,
.control-hidden .control-entry-link,
.control-hidden .control-entry-nav,
.control-hidden .callback-line,
.control-hidden .callback-ref,
.control-hidden h3.control-role,
.control-hidden h3.control-role + .mini-index {
  display: none;
}
.summary {
  display: none;
}
.card {
  margin: 0;
  padding: 7px 8px;
  border: 1px solid #e1e5ec;
  border-radius: 7px;
  background: rgba(255,255,255,.7);
}
.card b { display: block; color: var(--ink); margin: 0 0 1px; font-size: 12pt; }
.entry {
  margin: 0 0 1.35em;
  padding: 13px 15px 12px;
  border: 1px solid #e1e5ec;
  border-left: 4px solid var(--accent);
  border-radius: 7px;
  background: var(--paper);
  box-shadow: var(--shadow-small);
}
.entry dt {
  margin: 0 0 .35em;
  font: 700 14pt/1.35 Arial, Helvetica, sans-serif;
}
.entry dd { margin: .22em 0 .38em 0; }
.description { margin-bottom: .45em; }
.param-line { padding-left: 10.5em; text-indent: -10.5em; }
.param-label { font-weight: 700; }
.meta-line { color: var(--muted); font-size: 10pt; }
.source { color: var(--muted); font-size: 10pt; }
.muted { color: var(--muted); }
.doc-subtitle {
  color: var(--muted);
  font-size: 9.2pt;
  line-height: 1.3;
  padding-bottom: 8px;
  border-bottom: 1px solid #e4e0d8;
}
.sidebar-credit {
  position: fixed;
  left: 0;
  bottom: 0;
  width: var(--sidebar-width);
  box-sizing: border-box;
  padding: 9px 12px 10px;
  border-top: 1px solid var(--line);
  border-right: 1px solid var(--line);
  background: var(--sidebar-bg);
  color: var(--muted);
  font-size: 9.4pt;
  line-height: 1.32;
  z-index: 11;
}
.sidebar-credit a {
  font-weight: 700;
}
.control { color: var(--panel); font-family: "Courier New", Menlo, monospace; }
a { color: var(--link); text-decoration: none; }
a:hover { color: #083f78; text-decoration: underline; }
code, .sig, .s, .v, .w, .df, .kw-function, .fn-name {
  font-family: "Courier New", Menlo, Monaco, Consolas, monospace;
}
.kw-function { color: var(--keyword); font-weight: 700; }
.fn-name { color: var(--name); font-weight: 700; }
.s { color: var(--string); }
.v { color: var(--variable); }
.w { color: var(--wave); }
.df { color: var(--datafolder); }
.op { font-style: italic; color: var(--optional); }
.type { color: #999999; font-size: 90%; }
.tag {
  display: inline-block;
  min-width: 5.2em;
  margin-right: .45em;
  color: var(--muted);
  font-size: 9.2pt;
  text-transform: uppercase;
  letter-spacing: .02em;
}
.toc {
  margin: 12px 0 0;
  padding: 0;
  list-style: none;
}
.search-box {
  width: 100%;
  box-sizing: border-box;
  margin: 8px 0 4px;
  padding: 7px 8px;
  border: 1px solid var(--line);
  border-radius: 7px;
  background: #ffffff;
  font: 10pt "Courier New", Menlo, monospace;
  box-shadow: inset 0 1px 2px rgba(23, 25, 29, .04);
}
.search-box:focus {
  outline: 2px solid rgba(184, 135, 70, .28);
  border-color: var(--accent);
}
.search-note {
  color: var(--muted);
  font-size: 8.6pt;
  margin-bottom: 6px;
}
.search-results {
  max-height: 12em;
  overflow: auto;
  margin: 0 0 10px;
  border: 1px solid var(--line);
  border-radius: 7px;
  background: #fff;
  box-shadow: var(--shadow-small);
  display: none;
}
.search-results a {
  display: block;
  padding: 7px 9px;
  border-top: 1px solid #eeeeee;
  color: var(--ink);
  font-size: 9.5pt;
}
.search-results a:first-child { border-top: 0; }
.search-results a:hover { background: #fff7df; text-decoration: none; }
.search-page {
  color: var(--muted);
  display: block;
  font-size: 8.5pt;
}
.search-highlight {
  animation: kpSearchPulse 2.4s ease-out 1;
  outline: 4px solid #ffcc00;
  outline-offset: 3px;
  background: #fff4a3;
}
@keyframes kpSearchPulse {
  0% { background: #fff000; outline-color: #ff6600; }
  65% { background: #fff4a3; outline-color: #ffcc00; }
  100% { background: transparent; outline-color: transparent; }
}
.toc li { margin-bottom: .22em; }
.toc a { font-size: 10pt; }
.toc .count { color: var(--muted); font-size: 9pt; }
.nav-tree {
  margin: 8px 0 0;
  font-size: 9.6pt;
  overflow: auto;
  overscroll-behavior: contain;
  flex: 1 1 auto;
  min-height: 0;
  padding-right: 4px;
  padding-bottom: 12px;
}
.nav-tree details {
  margin: 4px 0;
  padding: 3px 0 4px;
  border-top: 1px solid #e8e1d6;
}
.nav-tree details:first-child { border-top: 0; }
.nav-tree summary {
  cursor: pointer;
  font-weight: 700;
  color: #252a31;
}
.nav-tree ul {
  list-style: none;
  margin: 4px 0 0 8px;
  padding: 0 0 0 9px;
  border-left: 2px solid #e5dfd3;
}
.nav-tree li { margin: 2px 0; }
.nav-tree a {
  font-size: 9.2pt;
  display: inline-block;
  color: #204a70;
}
.nav-tree .count {
  color: var(--muted);
  font-size: 8.4pt;
  font-weight: 400;
}
.mini-index {
  margin: 0 0 1.35em;
  padding: .72em .86em;
  border: 1px solid #e1e5ec;
  border-left: 5px solid var(--accent);
  border-radius: 7px;
  background: var(--soft);
  columns: 2;
}
.mini-index a {
  display: block;
  break-inside: avoid;
  font-family: "Courier New", Menlo, monospace;
  font-size: 10pt;
}
.featured-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
  gap: 12px;
  margin: 10px 0 20px;
}
.featured-cluster {
  margin: 16px 0 22px;
  padding: 14px 14px 4px;
  border: 1px solid #dfe4ec;
  border-radius: 8px;
  background: #ffffff;
  box-shadow: var(--shadow-small);
}
.featured-cluster h3 {
  margin: 0 0 3px;
  color: var(--procedure);
}
.featured-card {
  border: 1px solid #e3e7ee;
  border-radius: 7px;
  padding: 11px 12px;
  background: #fbfcfe;
}
.featured-card a {
  font: 700 12pt "Courier New", Menlo, monospace;
}
.featured-card b {
  display: block;
  margin: 3px 0 5px;
  color: var(--procedure);
}
.featured-card p {
  margin: 0;
  color: #333333;
  font-size: 10.5pt;
}
.summary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
  gap: 12px;
  margin: 1.1em 0 2em;
}
.metric-card {
  padding: 14px 15px;
  border: 1px solid #dfe4ec;
  border-left: 4px solid var(--accent);
  border-radius: 8px;
  background: #ffffff;
  box-shadow: var(--shadow-small);
}
.metric-card b {
  display: block;
  margin-bottom: 3px;
  color: var(--ink);
  font-size: 22pt;
  line-height: 1;
}
.metric-card span {
  color: var(--muted);
  font-size: 10pt;
}
.xref {
  font-weight: 700;
  border-bottom: 1px dotted currentColor;
}
.panel-image {
  width: 66.666%;
  margin: 14px 0 20px;
  background: var(--paper);
  border: 1px solid #dfe4ec;
  border-radius: 8px;
  box-sizing: border-box;
  box-shadow: var(--shadow);
  overflow: hidden;
}
.panel-image img {
  display: block;
  max-width: 100%;
  height: auto;
}
.panel-image figcaption {
  margin-top: 8px;
  color: var(--muted);
  font-size: 13px;
}
table { border-collapse: collapse; width: 100%; margin: 0 0 1.2em; }
th, td { padding: 6px 8px; border-top: 1px solid var(--line); vertical-align: top; }
th { color: var(--muted); text-align: left; font-size: 10pt; }
@media (max-width: 900px) {
  header {
    position: static;
    width: auto;
    border-right: 0;
    border-bottom: 1px solid var(--line);
  }
  .wrap { margin-left: 0; padding: 14px 16px 50px; }
  .sidebar-resizer { display: none; }
  .sidebar-credit {
    position: static;
    width: auto;
    margin-top: 16px;
    padding: 10px 0 0;
    border-right: 0;
    border-top: 1px solid var(--line);
  }
  .mini-index { columns: 1; }
  .panel-image {
    width: 100%;
  }
}
"""


def highlight_signature(sig: str) -> str:
    m = re.match(
        r"^(?P<prefix>\s*(?:Static\s+)?)"
        r"(?P<kind>Function(?:/[A-Za-z]+)?|Proc|Window|Macro|Menu)"
        r"(?P<space>\s+)"
        r"(?P<name>[A-Za-z_][A-Za-z0-9_]*|\"[^\"]+\")"
        r"(?P<rest>.*)$",
        sig,
        re.IGNORECASE,
    )
    if not m:
        return html.escape(sig)
    rest = highlight_signature_rest(m.group("rest"))
    return (
        html.escape(m.group("prefix"))
        + f'<span class="kw-function">{html.escape(display_kind(m.group("kind")))}</span>'
        + html.escape(m.group("space"))
        + f'<span class="fn-name">{html.escape(m.group("name"))}</span>'
        + rest
    )


def param_css_class(arg: str) -> tuple[str, str]:
    token = re.sub(r"[\[\]&$]", "", arg).strip()
    token = token.split("=", 1)[0].strip()
    low = token.lower()
    if not token:
        return "v", "variable"
    if "dfr" in low or "folder" in low:
        return "df", "datafolder"
    if low in {"w", "w1", "w2", "wg", "wi", "srcw", "destw"} or re.search(r"(wave|mat|matrix|grid|topo|roi|spec|img|image|trace|fft|map|cube)", low):
        return "w", "wave"
    if re.search(r"(name|str|path|file|folder|list|suffix|prefix|title|label|mode$)", low):
        return "s", "string"
    return "v", "variable"


def highlight_param(arg: str, optional: bool = False, include_type: bool = False) -> str:
    cls, typ = param_css_class(arg)
    token = html.escape(arg.strip())
    if optional:
        token = f'<span class="{cls} op">{token}</span>'
    else:
        token = f'<span class="{cls}">{token}</span>'
    if include_type:
        token += f' <span class="type">[{typ}]</span>'
    return token


def highlight_signature_rest(rest: str) -> str:
    start = rest.find("(")
    end = rest.find(")", start + 1)
    if start < 0 or end < 0:
        return html.escape(rest)
    before = html.escape(rest[: start + 1])
    args = rest[start + 1 : end]
    after = html.escape(rest[end:])
    out: list[str] = []
    optional = False
    for token in re.split(r"(,|\[|\])", args):
        if token == "[":
            optional = True
            out.append("[")
        elif token == "]":
            optional = False
            out.append("]")
        elif token == ",":
            out.append(", ")
        else:
            stripped = token.strip()
            if stripped:
                out.append(highlight_param(stripped, optional=optional))
    return before + "".join(out) + after


def entry_anchor(entry: dict) -> str:
    raw = f'{entry["name"]}-{entry["file"]}-{entry["line"]}'.lower()
    return re.sub(r"[^a-z0-9]+", "-", raw).strip("-")


def slugify(text: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")


def role_anchor(category: str, role: str) -> str:
    return slugify(f"{category}-{role}")


def entry_maps(entries: list[dict]) -> tuple[dict[str, dict], dict[str, str]]:
    by_name = {e["name"]: e for e in entries}
    anchors = {e["name"].lower(): entry_anchor(e) for e in entries}
    return by_name, anchors


def linkify_code_token(token: str, anchor_by_name: dict[str, str], *, prefix: str = "#") -> str:
    stripped = token.strip()
    m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*)(?:\([^`]*\))?$", stripped)
    if not m:
        return f"<code>{html.escape(token)}</code>"
    name = m.group(1)
    anchor = anchor_by_name.get(name.lower())
    if not anchor:
        return f"<code>{html.escape(token)}</code>"
    href = prefix + anchor
    return f'<code><a class="xref" href="{html.escape(href)}">{html.escape(token)}</a></code>'


def linkify_plain_text(text: str, anchor_by_name: dict[str, str], *, prefix: str = "#") -> str:
    call_re = re.compile(r"\b([A-Za-z_][A-Za-z0-9_]{2,})\s*\(([^)]{0,90})\)")
    out: list[str] = []
    pos = 0
    for m in call_re.finditer(text):
        name = m.group(1)
        anchor = anchor_by_name.get(name.lower())
        if not anchor:
            continue
        out.append(html.escape(text[pos : m.start()]))
        href = prefix + anchor
        out.append(f'<a class="xref" href="{html.escape(href)}">{html.escape(m.group(0))}</a>')
        pos = m.end()
    out.append(html.escape(text[pos:]))
    return "".join(out)


def linkify_text(text: str, anchor_by_name: dict[str, str], *, prefix: str = "#") -> str:
    parts = re.split(r"(`[^`]+`)", text)
    out: list[str] = []
    for part in parts:
        if not part:
            continue
        if part.startswith("`") and part.endswith("`"):
            out.append(linkify_code_token(part[1:-1], anchor_by_name, prefix=prefix))
        else:
            out.append(linkify_plain_text(part, anchor_by_name, prefix=prefix))
    return "".join(out)


def short_description_parts(description: str) -> dict[str, list[str]]:
    parts = {"purpose": [], "usage": [], "details": []}
    chunks = re.split(r"(?<=\.)\s+", description)
    for chunk in chunks:
        if not chunk:
            continue
        if chunk.startswith("Purpose:"):
            parts["purpose"].append(chunk.replace("Purpose:", "", 1).strip())
        elif chunk.startswith("Usage:"):
            parts["usage"].append(chunk.replace("Usage:", "", 1).strip())
        else:
            parts["details"].append(chunk)
    return parts


def md_description_lines(description: str) -> list[str]:
    parts = short_description_parts(description)
    lines: list[str] = []
    if parts["purpose"]:
        lines.append(f"- Purpose: {' '.join(parts['purpose'])}")
    if parts["usage"]:
        lines.append(f"- Usage: {' '.join(parts['usage'])}")
    if parts["details"]:
        lines.append(f"- Notes: {' '.join(parts['details'][:4])}")
    return lines


def first_meaningful_sentence(description: str) -> str:
    parts = short_description_parts(description)
    candidates = parts["purpose"] + parts["details"] + parts["usage"]
    for candidate in candidates:
        text = re.sub(r"`([^`]+)`", r"\1", candidate)
        text = re.sub(r"Panel control\(s\):.*", "", text).strip()
        if text:
            sentence = re.split(r"(?<=\.)\s+", text)[0].strip()
            return sentence[:320]
    return "Runs the linked KP routine for this panel workflow."


def panel_control_summary(control: dict, callback_entry: dict | None, target_entry: dict | None) -> str:
    title = clean_note_text(control.get("title") or control.get("control") or "control")
    target_name = target_entry["name"] if target_entry else ""
    callback_name = callback_entry["name"] if callback_entry else control.get("proc", "")
    base_entry = target_entry or callback_entry
    if base_entry:
        summary = first_meaningful_sentence(base_entry.get("description", ""))
    else:
        summary = "Static input/display control; no action procedure is attached."

    if target_name:
        return f"`{title}` runs `{target_name}()` through `{callback_name}`. {summary}"
    if callback_name:
        return f"`{title}` calls `{callback_name}`. {summary}"
    return f"`{title}` is a static panel control. {summary}"


def render_entry_definition(entry: dict, anchor_by_name: dict[str, str], control_link_by_key: dict[tuple[str, int, str], str] | None = None) -> str:
    parts = short_description_parts(entry["description"])
    args = signature_args(entry["signature"])
    controls = []
    for c in entry["controls"]:
        label = html.escape(c["title"] or c["control"])
        key = (c.get("file", ""), int(c.get("line") or 0), c.get("control", ""))
        href = (control_link_by_key or {}).get(key)
        if href:
            controls.append(f'<a class="control" href="{html.escape(href)}">{label}</a>')
        else:
            controls.append(f'<span class="control">{label}</span>')
    source = f'{html.escape(entry["file"])}:{entry["line"]}'
    dd: list[str] = []
    if parts["purpose"]:
        dd.append(f'<dd class="description"><span class="tag">Purpose</span>{" ".join(linkify_text(p, anchor_by_name) for p in parts["purpose"])}</dd>')
    if parts["usage"]:
        dd.append(f'<dd><span class="tag">Usage</span>{" ".join(linkify_text(p, anchor_by_name) for p in parts["usage"])}</dd>')
    if args:
        for arg in args[:10]:
            param_note = entry.get("param_docs", {}).get(arg, "")
            dd.append(
                '<dd class="param-line">'
                f'<span class="param-label">{highlight_param(arg, include_type=True)}:</span> '
                f'{html.escape(param_note)}'
                '</dd>'
            )
        if len(args) > 10:
            dd.append(f'<dd class="param-line"><span class="param-label">...</span> {len(args) - 10} additional parameters; see source for the full signature.</dd>')
    if controls:
        dd.append(f'<dd><span class="tag">Panel</span>{", ".join(controls[:8])}</dd>')
    if parts["details"]:
        dd.append(f'<dd><span class="tag">Notes</span>{" ".join(linkify_text(p, anchor_by_name) for p in parts["details"][:4])}</dd>')
    dd.append(f'<dd class="meta-line"><span class="tag">Source</span>{source}</dd>')
    cls = "entry control-entry" if entry.get("is_control_entry") else "entry"
    return "\n".join(
        [
            f'<dl class="{cls}" id="{entry_anchor(entry)}" data-search="{html.escape((entry["name"] + " " + entry["signature"] + " " + entry["description"] + " " + entry["file"]).lower())}">',
            f'<dt>{highlight_signature(entry["signature"])}</dt>',
            *dd,
            "</dl>",
        ]
    )


def result_excerpt(text: str, limit: int = 180) -> str:
    text = clean_note_text(re.sub(r"`([^`]+)`", r"\1", text))
    if len(text) > limit:
        return text[: limit - 1].rstrip() + "..."
    return text


def build_search_index(entries: list[dict], files: dict[str, list[str]], controls: list[dict]) -> list[dict]:
    index: list[dict] = []
    total_lines = sum(len(lines) for lines in files.values())
    index.append(
        {
            "title": "Package Summary",
            "kind": "Summary",
            "page": "Summary",
            "url": "SUMMARY.html#package-summary",
            "text": f"{BRAND} package summary statistics function proc window panel controls source code lines {total_lines}",
            "summary": "Package-level counts for source files, functions, procedures, panels, controls, and code lines.",
        }
    )
    for e in entries:
        index.append(
            {
                "title": e["name"],
                "kind": display_kind(e["kind"]),
                "page": "Function Book",
                "url": f"FUNCTION_BOOK.html#{entry_anchor(e)}",
                "text": " ".join([e["name"], e["signature"], e["description"], e["category"], e["file"]]),
                "summary": result_excerpt(e["description"]),
                "isControl": bool(e.get("is_control_entry")),
            }
        )

    entries_by_name = {e["name"]: e for e in entries}
    labels = [l for l in collect_draw_labels(files) if l["window"] == "Kong_Igor_panel" or l["file"] == "Kong_Igor_panel.ipf"]
    main_controls = [c for c in controls if c.get("window") == "Kong_Igor_panel" or c.get("file") == "Kong_Igor_panel.ipf"]
    for c in main_controls:
        section = nearest_section(c, labels)
        proc = c.get("proc", "")
        callback_entry = entries_by_name.get(proc)
        target = callback_entry.get("execute", "") if callback_entry else ""
        target_entry = entries_by_name.get(target) if target else None
        title = clean_note_text(c.get("title") or c.get("control") or "")
        control_id = panel_control_id(c, labels)
        summary = panel_control_summary(c, callback_entry, target_entry)
        index.append(
            {
                "title": title,
                "kind": "Panel Control",
                "page": "Panel Guide",
                "url": f"PANEL_GUIDE.html#{control_id}",
                "text": " ".join([title, c.get("control", ""), proc, target, section, summary, c.get("file", "")]),
                "summary": result_excerpt(summary),
            }
        )

    for w in [e for e in entries if e["kind"] == "Window"]:
        index.append(
            {
                "title": f'{w["name"]}()',
                "kind": "Window",
                "page": "Panel Guide",
                "url": f'PANEL_GUIDE.html#window-{entry_anchor(w)}',
                "text": " ".join([w["name"], w["description"], w["category"], w["file"]]),
                "summary": result_excerpt(w["description"]),
            }
        )
    return index


def render_featured_utilities(entries_by_name: dict[str, dict], anchor_by_name: dict[str, str]) -> str:
    groups: dict[str, list[str]] = defaultdict(list)
    for group, name, title, summary in FEATURED_FUNCTIONS:
        entry = entries_by_name.get(name)
        if entry is None:
            entry = next((e for e in entries_by_name.values() if e["name"].lower() == name.lower()), None)
        if not entry:
            continue
        anchor = entry_anchor(entry)
        groups[group].append(
            "\n".join(
                [
                    '<article class="featured-card">',
                    f'<a href="#{anchor}">{html.escape(entry["name"])}()</a>',
                    f'<b>{html.escape(title)}</b>',
                    f'<p>{linkify_text(summary, anchor_by_name)}</p>',
                    '</article>',
                ]
            )
        )
    if not groups:
        return ""
    sections = []
    for group, _name, _title, _summary in FEATURED_FUNCTIONS:
        cards = groups.pop(group, None)
        if not cards:
            continue
        sections.append(
            "\n".join(
                [
                    '<section class="featured-cluster">',
                    f'<h3>{html.escape(group)}</h3>',
                    f'<div class="featured-grid">{"".join(cards)}</div>',
                    '</section>',
                ]
            )
        )
    return (
        '<section id="featured-utilities">\n'
        '<h2>Featured Utilities</h2>\n'
        '<p>These entries are curated from the source code and the preserved update log. They highlight daily shortcuts, smart display tools, FFT/filter workflows, linecut extraction, and correction routines that are easy to reuse from the command line or from the panel.</p>\n'
        f'{"".join(sections)}\n'
        '</section>'
    )


def build_function_nav(entries: list[dict]) -> str:
    by_category: dict[str, list[dict]] = defaultdict(list)
    for e in entries:
        by_category[e["category"]].append(e)
    toc: list[str] = ['<li><a href="FUNCTION_BOOK.html#featured-utilities">Featured Utilities</a></li>']
    for category, _ in CATEGORY_RULES:
        items = by_category.get(category, [])
        if not items:
            continue
        role_nav = []
        for role in ROLE_ORDER:
            role_items = [e for e in items if e["role_group"] == role]
            if not role_items:
                continue
            nav_class = ' class="control-entry-nav"' if role == "Panel callbacks and control handlers" else ""
            role_nav.append(
                f'<li{nav_class}><a href="FUNCTION_BOOK.html#{role_anchor(category, role)}">{html.escape(role)}</a> '
                f'<span class="count">({len(role_items)})</span></li>'
            )
        toc.append(
            "\n".join(
                [
                    '<li><details>',
                    f'<summary>{html.escape(category)} <span class="count">({len(items)})</span></summary>',
                    '<ul>',
                    f'<li><a href="FUNCTION_BOOK.html#{slugify(category)}">Overview</a></li>',
                    *role_nav,
                    '</ul>',
                    '</details></li>',
                ]
            )
        )
    return "\n".join(toc)


def build_panel_nav(files: dict[str, list[str]], controls: list[dict]) -> str:
    labels = [l for l in collect_draw_labels(files) if l["window"] == "Kong_Igor_panel" or l["file"] == "Kong_Igor_panel.ipf"]
    main_controls = [c for c in controls if c.get("window") == "Kong_Igor_panel" or c.get("file") == "Kong_Igor_panel.ipf"]
    by_section: dict[str, list[dict]] = defaultdict(list)
    for c in main_controls:
        by_section[nearest_section(c, labels)].append(c)
    section_toc = []
    for section, items in sorted(by_section.items(), key=lambda kv: (min((c.get("y") or 9999 for c in kv[1])), min((c.get("x") or 9999 for c in kv[1])))):
        anchor = slugify(section) or "section"
        section_toc.append(f'<li><a href="PANEL_GUIDE.html#{anchor}">{html.escape(section)}</a> <span class="count">({len(items)})</span></li>')
    return "\n".join(
        [
            '<li><a href="PANEL_GUIDE.html#main-panel-map">Main Panel Map</a></li>',
            '<li><details open>',
            '<summary>Main Panel Sections</summary>',
            f'<ul>{chr(10).join(section_toc)}</ul>',
            '</details></li>',
            '<li><a href="PANEL_GUIDE.html#internal-windows">Internal Panels/Windows</a></li>',
        ]
    )


def documentation_nav() -> str:
    return "\n".join(
        [
            '<li><a href="PANEL_GUIDE.html">Panel Guide</a></li>',
            '<li><a href="FUNCTION_BOOK.html">Function Book</a></li>',
        ]
    )


def summary_nav() -> str:
    return '<li><a href="SUMMARY.html">Package Summary</a></li>'


def sidebar_credit() -> str:
    return (
        '<div class="sidebar-credit">'
        'Copyright &copy; 2026 '
        '<a href="https://www.westlake.edu.cn/faculty/lingyuan-kong.html" target="_blank" rel="noopener noreferrer">Lingyuan Kong</a>.<br>'
        f'{BRAND} is released under the <a href="../LICENSE">MIT License</a>.'
        '</div>'
    )


def search_script(search_index: list[dict]) -> str:
    payload = json.dumps(search_index, ensure_ascii=False)
    return f"""
<script>
const KP_SEARCH_INDEX = {payload};

function kpTerms(query) {{
  return query.trim().toLowerCase().split(/\\s+/).filter(Boolean);
}}

function kpHighlightTarget() {{
  if (!location.hash) return;
  const target = document.getElementById(decodeURIComponent(location.hash.slice(1)));
  if (!target) return;
  target.scrollIntoView({{ behavior: 'smooth', block: 'center' }});
  target.classList.remove('search-highlight');
  void target.offsetWidth;
  target.classList.add('search-highlight');
  setTimeout(() => target.classList.remove('search-highlight'), 2600);
}}

function kpOpenSearchResult(url) {{
  const [path, hash] = url.split('#');
  const here = location.pathname.split('/').pop();
  if (!path || path === here) {{
    if (hash) {{
      history.pushState(null, '', '#' + hash);
      kpHighlightTarget();
    }}
  }} else {{
    location.href = url;
  }}
}}

function kpToggleControlEntries(force) {{
  const next = typeof force === 'boolean' ? force : !document.body.classList.contains('control-hidden');
  document.body.classList.toggle('control-hidden', next);
  localStorage.setItem('kpHideControlEntries', next ? '1' : '0');
  const btn = document.getElementById('kpToggleControls');
  if (btn) btn.textContent = next ? 'Show callbacks' : 'Hide callbacks';
  for (const box of document.querySelectorAll('[data-kp-search]')) {{
    if (box.value) kpRenderSearch(box.id);
  }}
}}

function kpInstallSidebarResize() {{
  const handle = document.getElementById('kpSidebarResizer');
  if (!handle) return;
  const saved = localStorage.getItem('kpSidebarWidth');
  if (saved) document.documentElement.style.setProperty('--sidebar-width', saved);
  let dragging = false;
  handle.addEventListener('mousedown', (event) => {{
    dragging = true;
    event.preventDefault();
    document.body.style.userSelect = 'none';
  }});
  window.addEventListener('mousemove', (event) => {{
    if (!dragging) return;
    const width = Math.max(220, Math.min(680, event.clientX));
    const value = width + 'px';
    document.documentElement.style.setProperty('--sidebar-width', value);
    localStorage.setItem('kpSidebarWidth', value);
  }});
  window.addEventListener('mouseup', () => {{
    dragging = false;
    document.body.style.userSelect = '';
  }});
}}

function kpContainSidebarScroll() {{
  for (const scroller of document.querySelectorAll('.nav-tree, .search-results')) {{
    scroller.addEventListener('wheel', (event) => {{
      const atTop = scroller.scrollTop <= 0;
      const atBottom = Math.ceil(scroller.scrollTop + scroller.clientHeight) >= scroller.scrollHeight;
      if ((event.deltaY < 0 && atTop) || (event.deltaY > 0 && atBottom)) {{
        event.preventDefault();
      }}
      event.stopPropagation();
    }}, {{ passive: false }});
  }}
}}

function kpRenderSearch(inputId) {{
  const box = document.getElementById(inputId);
  if (!box) return;
  const resultBox = document.getElementById(box.dataset.results);
  if (!resultBox) return;
  const terms = kpTerms(box.value);
  if (terms.length === 0) {{
    resultBox.style.display = 'none';
    resultBox.innerHTML = '';
    return;
  }}
  const hits = KP_SEARCH_INDEX
    .map((item) => {{
      if (document.body.classList.contains('control-hidden') && item.isControl) return null;
      const text = (item.text || '').toLowerCase();
      if (!terms.every((term) => text.includes(term))) return null;
      let score = 0;
      const title = (item.title || '').toLowerCase();
      const normalizedTitle = title.replace(/\\(\\)$/,'');
      const query = terms.join(' ');
      for (const term of terms) {{
        if (normalizedTitle === term || title === term) score += 100;
        else if (normalizedTitle.startsWith(term) || title.startsWith(term)) score += 50;
        else if (title.includes(term)) score += 10;
        if (text.split(/\\s+/).includes(term)) score += 4;
        if ((item.kind || '').toLowerCase().includes(term)) score += 2;
        if ((item.page || '').toLowerCase().includes(term)) score += 1;
      }}
      if (normalizedTitle === query || title === query) score += 120;
      return {{...item, score}};
    }})
    .filter(Boolean)
    .sort((a, b) => b.score - a.score || a.title.localeCompare(b.title))
    .slice(0, 40);

  const esc = (value) => String(value || '').replace(/[&<>"']/g, (ch) => ({{'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}}[ch]));
  resultBox.innerHTML = hits.length
    ? hits.map((item, i) => `
        <a href="${{esc(item.url)}}" data-url="${{esc(item.url)}}" data-search-result="${{i}}">
          <strong>${{esc(item.title)}}</strong> <span class="type">[${{esc(item.kind)}}]</span>
          <span class="search-page">${{esc(item.page)}} · ${{esc(item.summary)}}</span>
        </a>`).join('')
    : '<div class="search-note">No match in Function Book or Panel Guide.</div>';
  resultBox.style.display = 'block';
  for (const link of resultBox.querySelectorAll('[data-url]')) {{
    link.addEventListener('click', (event) => {{
      event.preventDefault();
      kpOpenSearchResult(link.dataset.url);
    }});
  }}
}}

document.addEventListener('DOMContentLoaded', () => {{
  kpInstallSidebarResize();
  kpContainSidebarScroll();
  kpToggleControlEntries(localStorage.getItem('kpHideControlEntries') === '1');
  const toggle = document.getElementById('kpToggleControls');
  if (toggle) toggle.addEventListener('click', () => kpToggleControlEntries());
  const back = document.getElementById('kpBackButton');
  if (back) back.addEventListener('click', () => {{
    if (history.length > 1) history.back();
    else if (back.dataset.fallback) location.href = back.dataset.fallback;
  }});
  for (const box of document.querySelectorAll('[data-kp-search]')) {{
    box.addEventListener('input', () => kpRenderSearch(box.id));
    box.addEventListener('keydown', (event) => {{
      if (event.key !== 'Enter') return;
      const resultBox = document.getElementById(box.dataset.results);
      const first = resultBox && resultBox.querySelector('[data-url]');
      if (first) {{
        event.preventDefault();
        kpOpenSearchResult(first.dataset.url);
      }}
    }});
  }}
  kpHighlightTarget();
}});
window.addEventListener('hashchange', kpHighlightTarget);
</script>
"""


def render_html(entries: list[dict], files: dict[str, list[str]], controls: list[dict], search_index: list[dict]) -> str:
    by_category: dict[str, list[dict]] = defaultdict(list)
    by_kind: dict[str, int] = defaultdict(int)
    entries_by_name, anchor_by_name = entry_maps(entries)
    panel_labels = [l for l in collect_draw_labels(files) if l["window"] == "Kong_Igor_panel" or l["file"] == "Kong_Igor_panel.ipf"]
    control_link_by_key: dict[tuple[str, int, str], str] = {}
    for c in controls:
        if c.get("window") == "Kong_Igor_panel" or c.get("file") == "Kong_Igor_panel.ipf":
            control_link_by_key[(c.get("file", ""), int(c.get("line") or 0), c.get("control", ""))] = f'PANEL_GUIDE.html#{panel_control_id(c, panel_labels)}'
    for e in entries:
        by_category[e["category"]].append(e)
        by_kind[display_kind(e["kind"]).split("/")[0]] += 1
    rows = []
    toc = []
    for category, _ in CATEGORY_RULES:
        items = by_category.get(category, [])
        if not items:
            continue
        anchor = slugify(category)
        role_nav = []
        group_rows = []
        for role in ROLE_ORDER:
            role_items = [e for e in items if e["role_group"] == role]
            if not role_items:
                continue
            role_id = role_anchor(category, role)
            nav_class = ' class="control-entry-nav"' if role == "Panel callbacks and control handlers" else ""
            role_nav.append(f'<li{nav_class}><a href="#{role_id}">{html.escape(role)}</a> <span class="count">({len(role_items)})</span></li>')
            sorted_items = sorted(role_items, key=lambda x: (x["name"].lower(), x["file"], x["line"]))
            mini = "".join(
                f'<a class="{"control-entry-link" if e.get("is_control_entry") else ""}" href="#{entry_anchor(e)}">{html.escape(e["name"])}</a>'
                for e in sorted_items[:80]
            )
            if len(sorted_items) > 80:
                mini += f'<span class="muted">+ {len(sorted_items) - 80} more entries below</span>'
            role_class = "control-role" if role == "Panel callbacks and control handlers" else ""
            group_rows.append(f'\n<h3 id="{role_id}" class="{role_class}">{html.escape(role)} <span class="muted">({len(role_items)})</span></h3>')
            group_rows.append(f'<div class="mini-index">{mini}</div>')
            group_rows.extend(render_entry_definition(e, anchor_by_name, control_link_by_key) for e in sorted_items)
        toc.append(
            "\n".join(
                [
                    '<li><details>',
                    f'<summary>{html.escape(category)} <span class="count">({len(items)})</span></summary>',
                    '<ul>',
                    f'<li><a href="#{anchor}">Overview</a></li>',
                    *role_nav,
                    '</ul>',
                    '</details></li>',
                ]
            )
        )
        rows.append(
            f'\n<section id="{anchor}">\n<h2>{html.escape(category)}</h2>'
            f"{''.join(group_rows)}\n</section>"
        )
    featured = render_featured_utilities(entries_by_name, anchor_by_name)
    function_nav = build_function_nav(entries)
    panel_nav = build_panel_nav(files, controls)
    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>{BRAND} Function Book</title>
<style>{css()}</style>
</head>
<body>
<header>
  <h1>{BRAND} Function Book</h1>
  <div class="doc-subtitle">Procedure library for STM/STS analysis, FFT workflows, linecuts, fitting, lattice tools, and modeling.</div>
  <div class="toolbar">
    <button class="tool-button" id="kpBackButton" data-fallback="PANEL_GUIDE.html" type="button">Back</button>
    <a class="tool-button" href="PANEL_GUIDE.html">Panel Guide</a>
    <button class="tool-button" id="kpToggleControls" type="button">Hide callbacks</button>
  </div>
  <input id="kpFunctionSearch" class="search-box" data-kp-search data-results="kpFunctionSearchResults" type="search" placeholder="Search all docs..." aria-label="Search all {BRAND} documentation">
  <div class="search-note">Search all docs; Enter jumps to the first match.</div>
  <div id="kpFunctionSearchResults" class="search-results" aria-live="polite"></div>
  <nav class="nav-tree" aria-label="{BRAND} documentation map">
    <details open>
      <summary>Documentation</summary>
      <ul>
        {documentation_nav()}
      </ul>
    </details>
    <details>
      <summary>Panel Guide</summary>
      <ul>
        {panel_nav}
      </ul>
    </details>
    <details open>
      <summary>Function Book</summary>
      <ul>
        {function_nav}
      </ul>
    </details>
    <details>
      <summary>Summary</summary>
      <ul>
        {summary_nav()}
      </ul>
    </details>
  </nav>
  {sidebar_credit()}
</header>
<div class="sidebar-resizer" id="kpSidebarResizer" aria-hidden="true"></div>
<main class="wrap">
  <h2>How to use this book</h2>
  <p>This manual follows a procedure-library layout: choose a workflow on the left, then jump to a function or procedure name inside that group. Signatures use Igor-style coloring: <span class="w">waves</span>, <span class="s">strings</span>, <span class="v">variables</span>, and <span class="df">data folders</span>; optional arguments are italicized.</p>
  <p>Each entry lists purpose, usage, panel controls when available, inferred notes, and source file/line for quick code navigation.</p>
  <p>For the panel layout and button-to-code map, open <a href="PANEL_GUIDE.html">PANEL_GUIDE.html</a>.</p>
  {featured}
  {''.join(rows)}
</main>
{search_script(search_index)}
</body>
</html>
"""


def render_summary_html(entries: list[dict], files: dict[str, list[str]], controls: list[dict], search_index: list[dict]) -> str:
    function_nav = build_function_nav(entries)
    panel_nav = build_panel_nav(files, controls)
    kind_counts: dict[str, int] = defaultdict(int)
    for e in entries:
        kind_counts[display_kind(e["kind"]).split("/")[0]] += 1
    labels = [l for l in collect_draw_labels(files) if l["window"] == "Kong_Igor_panel" or l["file"] == "Kong_Igor_panel.ipf"]
    main_controls = [c for c in controls if c.get("window") == "Kong_Igor_panel" or c.get("file") == "Kong_Igor_panel.ipf"]
    main_sections = {nearest_section(c, labels) for c in main_controls}
    source_lines = sum(len(lines) for lines in files.values())
    nonblank_lines = sum(1 for lines in files.values() for line in lines if line.strip())
    callback_controls = sum(1 for c in controls if c.get("proc"))
    workflow_groups = len({e["category"] for e in entries})
    metrics = [
        ("IPF files", len(files)),
        ("Total source lines", source_lines),
        ("Non-empty source lines", nonblank_lines),
        ("Function entries", kind_counts.get("Function", 0)),
        ("Procedure entries", kind_counts.get("Proc", 0)),
        ("Macro entries", kind_counts.get("Macro", 0)),
        ("Window / panel definitions", kind_counts.get("Window", 0)),
        ("Main panel controls", len(main_controls)),
        ("Main panel sections", len(main_sections)),
        ("Parsed control callbacks", callback_controls),
        ("Workflow groups", workflow_groups),
        ("Catalog entries", len(entries)),
    ]
    metric_cards = "".join(
        f'<article class="metric-card"><b>{value}</b><span>{html.escape(label)}</span></article>'
        for label, value in metrics
    )
    kind_rows = "".join(
        f"<tr><td>{html.escape(kind)}</td><td>{count}</td></tr>"
        for kind, count in sorted(kind_counts.items())
    )
    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>{BRAND} Summary</title>
<style>{css()}</style>
</head>
<body>
<header>
  <h1>{BRAND} Summary</h1>
  <div class="doc-subtitle">Package-level counts for the source release and generated documentation.</div>
  <div class="toolbar">
    <button class="tool-button" id="kpBackButton" data-fallback="PANEL_GUIDE.html" type="button">Back</button>
    <a class="tool-button" href="PANEL_GUIDE.html">Panel Guide</a>
    <a class="tool-button" href="FUNCTION_BOOK.html">Function Book</a>
  </div>
  <input id="kpSummarySearch" class="search-box" data-kp-search data-results="kpSummarySearchResults" type="search" placeholder="Search all docs..." aria-label="Search all {BRAND} documentation">
  <div class="search-note">Search all docs; Enter jumps to the first match.</div>
  <div id="kpSummarySearchResults" class="search-results" aria-live="polite"></div>
  <nav class="nav-tree" aria-label="{BRAND} documentation map">
    <details open>
      <summary>Documentation</summary>
      <ul>
        {documentation_nav()}
      </ul>
    </details>
    <details>
      <summary>Panel Guide</summary>
      <ul>
        {panel_nav}
      </ul>
    </details>
    <details>
      <summary>Function Book</summary>
      <ul>
        {function_nav}
      </ul>
    </details>
    <details open>
      <summary>Summary</summary>
      <ul>
        {summary_nav()}
      </ul>
    </details>
  </nav>
  {sidebar_credit()}
</header>
<div class="sidebar-resizer" id="kpSidebarResizer" aria-hidden="true"></div>
<main class="wrap">
  <h2 id="package-summary">Package Summary</h2>
  <p>This page keeps the package statistics out of the fixed navigation area while preserving a quick overview of the source release.</p>
  <div class="summary-grid">{metric_cards}</div>
  <h2>Entry Type Counts</h2>
  <table>
    <thead><tr><th>Entry type</th><th>Count</th></tr></thead>
    <tbody>{kind_rows}</tbody>
  </table>
</main>
{search_script(search_index)}
</body>
</html>
"""


def render_md(entries: list[dict]) -> str:
    by_category: dict[str, list[dict]] = defaultdict(list)
    for e in entries:
        by_category[e["category"]].append(e)
    lines = [
        f"# {BRAND} Function Index",
        "",
        "This Markdown index is generated from `src/*.ipf` and organized by workflow rather than by IPF file. For the color-coded manual, open `docs/FUNCTION_BOOK.html`.",
        "",
        "The HTML manual is the preferred browsing format. This Markdown version keeps the same workflow order for GitHub text search.",
        "",
        f"Total entries: {len(entries)}",
        "",
    ]
    for category, _ in CATEGORY_RULES:
        items = by_category.get(category, [])
        if not items:
            continue
        lines += [f"## {category}", ""]
        for role in ROLE_ORDER:
            role_items = [e for e in items if e["role_group"] == role]
            if not role_items:
                continue
            lines += [f"### {role}", ""]
            for e in sorted(role_items, key=lambda x: (x["name"].lower(), x["file"], x["line"])):
                source = f"{e['file']}:{e['line']}"
                lines.append(f"#### `{e['name']}`")
                lines.append("")
                lines.append(f"```igor")
                lines.append(e["signature"])
                lines.append("```")
                lines.extend(md_description_lines(e["description"]))
                args = signature_args(e["signature"])
                if args:
                    lines.append("- Parameters:")
                    for arg in args[:10]:
                        note = e.get("param_docs", {}).get(arg, "")
                        lines.append(f"  - `{arg}`: {note}")
                    if len(args) > 10:
                        lines.append(f"  - ... {len(args) - 10} additional parameters")
                controls = [c.get("title") or c.get("control") for c in e.get("controls", [])]
                if controls:
                    lines.append("- Panel controls: " + ", ".join(f"`{c}`" for c in controls[:8]))
                lines.append(f"- Source: `{source}`")
                lines.append("")
            lines.append("")
        lines.append("")
    return "\n".join(lines)


def collect_draw_labels(files: dict[str, list[str]]) -> list[dict]:
    labels: list[dict] = []
    for file, lines in files.items():
        current_window = ""
        for i, line in enumerate(lines, 1):
            wm = WINDOW_START_RE.match(line)
            if wm:
                current_window = wm.group("name")
            m = DRAW_TEXT_RE.match(line)
            if not m:
                continue
            text = clean_note_text(m.group("text"))
            if not text:
                continue
            labels.append(
                {
                    "file": file,
                    "line": i,
                    "window": current_window,
                    "x": float(m.group("x")),
                    "y": float(m.group("y")),
                    "text": text,
                }
            )
    return labels


def nearest_section(control: dict, labels: list[dict]) -> str:
    if control.get("x") is None or control.get("y") is None:
        return "Unplaced controls"
    x = float(control["x"])
    y = float(control["y"])
    candidates = [l for l in labels if l["y"] <= y + 12]
    if not candidates:
        candidates = labels
    best = min(
        candidates,
        key=lambda l: abs(y - l["y"]) + 0.28 * abs(x - l["x"]) + (0 if l["y"] <= y + 12 else 80),
    )
    if abs(y - best["y"]) > 125 and abs(x - best["x"]) > 180:
        return "General / nearby controls"
    return best["text"]


def panel_control_id(control: dict, labels: list[dict]) -> str:
    section = control.get("section") or nearest_section(control, labels)
    return re.sub(
        r"[^a-z0-9]+",
        "-",
        f'{section}-{control.get("control")}-{control.get("line")}'.lower(),
    ).strip("-")


def window_controls_for(files: dict[str, list[str]], controls: list[dict], window_name: str) -> list[dict]:
    return [c for c in controls if c.get("window") == window_name]


def svg_text(text: str, max_chars: int) -> str:
    text = clean_note_text(text)
    if len(text) > max_chars:
        return text[: max(1, max_chars - 1)] + "…"
    return text


def render_panel_svg(files: dict[str, list[str]], controls: list[dict]) -> str:
    labels = [l for l in collect_draw_labels(files) if l["window"] == "Kong_Igor_panel" or l["file"] == "Kong_Igor_panel.ipf"]
    main_controls = [
        c
        for c in controls
        if c.get("window") == "Kong_Igor_panel" or c.get("file") == "Kong_Igor_panel.ipf"
    ]
    placed_controls = [c for c in main_controls if c.get("x") is not None and c.get("y") is not None]
    placed_labels = [l for l in labels if l.get("x") is not None and l.get("y") is not None]
    width = int(max([610] + [float(c.get("x") or 0) + float(c.get("w") or 50) + 8 for c in placed_controls]))
    height = int(max([860] + [float(c.get("y") or 0) + float(c.get("h") or 14) + 8 for c in placed_controls]))
    sections = sorted({nearest_section(c, labels) for c in placed_controls})
    section_color = {s: SECTION_COLORS[i % len(SECTION_COLORS)] for i, s in enumerate(sections)}
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}" role="img" aria-labelledby="title desc">',
        f"<title>{BRAND} main interface map</title>",
        "<desc>Reconstructed from Kong_Igor_panel.ipf: section labels, buttons, controls, and approximate positions.</desc>",
        '<rect x="0" y="0" width="100%" height="100%" fill="#00cc00"/>',
        '<style>text{font-family:Arial,Helvetica,sans-serif}.section{font-family:Georgia,serif;font-size:15px;font-weight:700;fill:white}.button{font-size:9px;fill:#111}.small{font-size:7px;fill:#111}.source{font-size:7px;fill:#333}</style>',
    ]
    for l in placed_labels:
        color = section_color.get(l["text"], "#111")
        x = float(l["x"]) - 3
        y = max(0.0, float(l["y"]) - 18)
        w = min(width - x - 2, max(80.0, len(l["text"]) * 8.0 + 10))
        h = 22
        parts.append(f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h}" fill="{color}" opacity="0.92"/>')
        parts.append(f'<text class="section" x="{x+4:.1f}" y="{y+16:.1f}">{html.escape(svg_text(l["text"], 24))}</text>')
    for c in placed_controls:
        title = c.get("title") or c.get("control")
        x = float(c.get("x") or 0)
        y = float(c.get("y") or 0)
        w = max(18.0, float(c.get("w") or 45))
        h = max(11.0, float(c.get("h") or 14))
        kind = c.get("control_kind", "").lower()
        if kind == "button":
            fill, stroke = "#f5f5f5", "#777"
        elif kind == "popupmenu":
            fill, stroke = "#e8f2ff", "#1677c4"
        elif kind == "setvariable":
            fill, stroke = "#fff7cc", "#b08900"
        else:
            fill, stroke = "#eeeeee", "#777"
        if c.get("disable") == 1:
            opacity = "0.72"
        else:
            opacity = "1"
        rx = min(5.0, h / 3)
        parts.append(
            f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" rx="{rx:.1f}" fill="{fill}" stroke="{stroke}" stroke-width="0.8" opacity="{opacity}">'
            f'<title>{html.escape(title)} -> {html.escape(c.get("proc",""))} ({html.escape(c.get("file",""))}:{c.get("line","")})</title></rect>'
        )
        max_chars = max(3, int(w / 5.1))
        if "\n" in title or " / " in title:
            split = re.split(r"\s*/\s*|\n", title, maxsplit=1)
        else:
            split = [title]
        if len(split) > 1 and h >= 18:
            parts.append(f'<text class="button" text-anchor="middle" x="{x+w/2:.1f}" y="{y+h/2-1:.1f}">{html.escape(svg_text(split[0], max_chars))}</text>')
            parts.append(f'<text class="button" text-anchor="middle" x="{x+w/2:.1f}" y="{y+h/2+10:.1f}">{html.escape(svg_text(split[1], max_chars))}</text>')
        else:
            cls = "small" if h < 14 or w < 35 else "button"
            parts.append(f'<text class="{cls}" text-anchor="middle" x="{x+w/2:.1f}" y="{y+h/2+3:.1f}">{html.escape(svg_text(title, max_chars))}</text>')
    parts.append("</svg>")
    return "\n".join(parts)


def render_panel_html(entries: list[dict], files: dict[str, list[str]], controls: list[dict], search_index: list[dict]) -> str:
    entries_by_name, anchor_by_name = entry_maps(entries)
    all_labels = collect_draw_labels(files)
    main_labels = [l for l in all_labels if l["window"] == "Kong_Igor_panel" or l["file"] == "Kong_Igor_panel.ipf"]
    main_controls = [
        c
        for c in controls
        if c.get("window") == "Kong_Igor_panel" or c.get("file") == "Kong_Igor_panel.ipf"
    ]
    for c in main_controls:
        c["section"] = nearest_section(c, main_labels)
    by_section: dict[str, list[dict]] = defaultdict(list)
    for c in main_controls:
        by_section[c["section"]].append(c)

    section_rows = []
    for section, items in sorted(by_section.items(), key=lambda kv: (min((c.get("y") or 9999 for c in kv[1])), min((c.get("x") or 9999 for c in kv[1])))):
        anchor = slugify(section) or "section"
        mini_links = []
        rows = []
        for c in sorted(items, key=lambda x: ((x.get("y") if x.get("y") is not None else 9999), (x.get("x") if x.get("x") is not None else 9999))):
            proc = c.get("proc", "")
            entry = entries_by_name.get(proc)
            target = entry.get("execute", "") if entry else ""
            target_entry = entries_by_name.get(target) if target else None
            note = panel_control_summary(c, entry, target_entry)
            source = f'{c.get("file")}:{c.get("line")}'
            control_id = panel_control_id(c, main_labels)
            title = c.get("title") or c.get("control")
            mini_links.append(f'<a href="#{control_id}">{html.escape(title)}</a>')
            dd = [
                f'<dd class="description callback-line"><span class="tag">Action</span>'
                f'{linkify_code_token(proc, anchor_by_name, prefix="FUNCTION_BOOK.html#")}'
                f'{" -> "+linkify_code_token(target+"()", anchor_by_name, prefix="FUNCTION_BOOK.html#") if target else ""}</dd>',
                f'<dd><span class="tag">Control</span><span class="control">{html.escape(c.get("control",""))}</span> '
                f'<span class="type">[{html.escape(display_kind(c.get("control_kind","")))}]</span></dd>',
                f'<dd><span class="tag">What</span>{linkify_text(note, anchor_by_name, prefix="FUNCTION_BOOK.html#")}</dd>',
                f'<dd class="meta-line"><span class="tag">Source</span>{html.escape(source)}</dd>',
            ]
            rows.append(
                "\n".join(
                    [
                        f'<dl class="entry" id="{control_id}" data-search="{html.escape((title + " " + proc + " " + target + " " + note + " " + source).lower())}">',
                        f'<dt><span class="control">{html.escape(title)}</span></dt>',
                        f'<dd><span class="tag">Summary</span>{linkify_text(note, anchor_by_name, prefix="FUNCTION_BOOK.html#")}</dd>',
                        *dd,
                        "</dl>",
                    ]
                )
            )
        section_rows.append(
            f'\n<section id="{anchor}">\n<h2>{html.escape(section)} <span class="muted">({len(items)} controls)</span></h2>'
            f'<div class="mini-index">{"".join(mini_links)}</div>'
            f'{"".join(rows)}\n</section>'
        )

    windows = [e for e in entries if e["kind"] == "Window"]
    window_rows = []
    for w in sorted(windows, key=lambda e: (e["category"], e["name"].lower())):
        wcontrols = window_controls_for(files, controls, w["name"])
        controls_text = ", ".join(
            f'<span class="control">{html.escape(c.get("title") or c.get("control"))}</span>'
            + (f' <span class="callback-ref">-> {linkify_code_token(c.get("proc",""), anchor_by_name, prefix="FUNCTION_BOOK.html#")}</span>' if c.get("proc") else "")
            for c in wcontrols[:12]
        )
        if len(wcontrols) > 12:
            controls_text += f' <span class="muted">+{len(wcontrols)-12} more</span>'
        if not controls_text:
            controls_text = '<span class="muted">No explicit controls parsed; likely a graph/window recreation.</span>'
        window_rows.append(
            "\n".join(
                [
                    f'<dl class="entry" id="window-{entry_anchor(w)}" data-search="{html.escape((w["name"] + " " + w["description"] + " " + w["category"] + " " + w["file"]).lower())}">',
                    f'<dt><span class="fn-name">{html.escape(w["name"])}</span>()</dt>',
                    f'<dd class="description"><span class="tag">Purpose</span>{linkify_text(w["description"], anchor_by_name, prefix="FUNCTION_BOOK.html#")}</dd>',
                    f'<dd><span class="tag">Group</span>{html.escape(w["category"])}</dd>',
                    f'<dd><span class="tag">Controls</span>{controls_text}</dd>',
                    f'<dd class="meta-line"><span class="tag">Source</span>{html.escape(w["file"])}:{w["line"]}</dd>',
                    '</dl>',
                ]
            )
        )

    section_toc = []
    for section, items in sorted(by_section.items(), key=lambda kv: (min((c.get("y") or 9999 for c in kv[1])), min((c.get("x") or 9999 for c in kv[1])))):
        anchor = slugify(section) or "section"
        section_toc.append(f'<li><a href="#{anchor}">{html.escape(section)}</a> <span class="count">({len(items)})</span></li>')
    function_nav = build_function_nav(entries)
    panel_nav = build_panel_nav(files, controls)

    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>{BRAND} Guide</title>
<style>{css()}</style>
</head>
<body>
<header>
  <h1>{BRAND} Guide</h1>
  <div class="doc-subtitle">Visual map of the main panel, internal windows, and procedures behind each control.</div>
  <div class="toolbar">
    <button class="tool-button" id="kpBackButton" data-fallback="FUNCTION_BOOK.html" type="button">Back</button>
    <a class="tool-button" href="FUNCTION_BOOK.html">Function Book</a>
    <button class="tool-button" id="kpToggleControls" type="button">Hide callbacks</button>
  </div>
  <input id="kpPanelSearch" class="search-box" data-kp-search data-results="kpPanelSearchResults" type="search" placeholder="Search all docs..." aria-label="Search all {BRAND} documentation">
  <div class="search-note">Search all docs; Enter jumps to the first match.</div>
  <div id="kpPanelSearchResults" class="search-results" aria-live="polite"></div>
  <nav class="nav-tree" aria-label="{BRAND} documentation map">
    <details open>
      <summary>Documentation</summary>
      <ul>
        {documentation_nav()}
      </ul>
    </details>
    <details open>
      <summary>Panel Guide</summary>
      <ul>
        {panel_nav}
      </ul>
    </details>
    <details>
      <summary>Function Book</summary>
      <ul>
        {function_nav}
      </ul>
    </details>
    <details>
      <summary>Summary</summary>
      <ul>
        {summary_nav()}
      </ul>
    </details>
  </nav>
  {sidebar_credit()}
</header>
<div class="sidebar-resizer" id="kpSidebarResizer" aria-hidden="true"></div>
<main class="wrap">
  <h2 id="main-panel-map">Main Panel Map</h2>
  <figure class="panel-image"><img src="assets/kong_panel_main.png" alt="{BRAND} main interface"><figcaption>Main {BRAND} interface.</figcaption></figure>
  <p>This guide follows the visual logic of the panel. Choose a colored section from the left index, then jump to a visible button/control name. Each control entry lists the Igor action procedure, the wrapped command when present, the inferred purpose, and the source line.</p>
  {''.join(section_rows)}
  <h2 id="internal-windows">Internal Panels and Secondary Windows</h2>
  <p>Many KP buttons open helper panels, graph windows, or interactive control strips. This table lists all parsed <code>Window</code> definitions and the controls found inside each window body.</p>
  {''.join(window_rows)}
</main>
{search_script(search_index)}
</body>
</html>
"""


def render_panel_md(entries: list[dict], files: dict[str, list[str]], controls: list[dict]) -> str:
    entries_by_name = {e["name"]: e for e in entries}
    labels = [l for l in collect_draw_labels(files) if l["window"] == "Kong_Igor_panel" or l["file"] == "Kong_Igor_panel.ipf"]
    main_controls = [c for c in controls if c.get("window") == "Kong_Igor_panel" or c.get("file") == "Kong_Igor_panel.ipf"]
    for c in main_controls:
        c["section"] = nearest_section(c, labels)
    by_section: dict[str, list[dict]] = defaultdict(list)
    for c in main_controls:
        by_section[c["section"]].append(c)
    lines = [
        f"# {BRAND} Guide",
        "",
        "This guide is generated from `Kong_Igor_panel.ipf` and the compiled source catalog. The HTML version, `PANEL_GUIDE.html`, is the preferred browsing format because it keeps the main-panel sections in a fixed navigation index.",
        "",
        f"![{BRAND} main interface](assets/kong_panel_main.png)",
        "",
        f"- Main panel controls: {len(main_controls)}",
        f"- Main panel sections: {len(by_section)}",
        f"- Window/panel definitions: {sum(1 for e in entries if e['kind'] == 'Window')}",
        "",
    ]
    for section, items in sorted(by_section.items(), key=lambda kv: (min((c.get("y") or 9999 for c in kv[1])), min((c.get("x") or 9999 for c in kv[1])))):
        lines += [f"## {section}", ""]
        for c in sorted(items, key=lambda x: ((x.get("y") if x.get("y") is not None else 9999), (x.get("x") if x.get("x") is not None else 9999))):
            proc = c.get("proc", "")
            entry = entries_by_name.get(proc)
            target = entry.get("execute", "") if entry else ""
            target_entry = entries_by_name.get(target) if target else None
            note = panel_control_summary(c, entry, target_entry)
            action = f"`{proc}`" + (f" -> `{target}()`" if target else "")
            lines.append(f"### `{c.get('title') or c.get('control')}`")
            lines.append("")
            lines.append(f"- Summary: {note}")
            lines.append(f"- Control: `{c.get('control')}` `{c.get('control_kind','')}`")
            lines.append(f"- Action: {action}")
            lines.append(f"- Source: `{c.get('file')}:{c.get('line')}`")
            lines.append("")
        lines.append("")
    lines += ["## Internal Panels and Secondary Windows", ""]
    for w in sorted([e for e in entries if e["kind"] == "Window"], key=lambda e: (e["category"], e["name"].lower())):
        lines.append(f"### `{w['name']}()`")
        lines.append("")
        lines.append(f"- Workflow group: {w['category']}")
        lines.append(f"- Purpose: {w['description']}")
        lines.append(f"- Source: `{w['file']}:{w['line']}`")
        lines.append("")
    lines.append("")
    return "\n".join(lines)


def main() -> None:
    DOCS.mkdir(exist_ok=True)
    ASSETS.mkdir(exist_ok=True)
    files = read_files()
    control_defs = parse_control_lines(files)
    controls = defaultdict(list)
    for rec in control_defs:
        if rec.get("proc"):
            controls[rec["proc"]].append(rec)
    entries = collect_entries(files, controls)
    search_index = build_search_index(entries, files, control_defs)
    (DOCS / "function_catalog.json").write_text(json.dumps(entries, indent=2), encoding="utf-8")
    (DOCS / "panel_catalog.json").write_text(json.dumps(control_defs, indent=2), encoding="utf-8")
    (DOCS / "FUNCTION_BOOK.html").write_text(render_html(entries, files, control_defs, search_index), encoding="utf-8")
    (DOCS / "FUNCTION_INDEX.md").write_text(render_md(entries), encoding="utf-8")
    (DOCS / "PANEL_GUIDE.html").write_text(render_panel_html(entries, files, control_defs, search_index), encoding="utf-8")
    (DOCS / "PANEL_GUIDE.md").write_text(render_panel_md(entries, files, control_defs), encoding="utf-8")
    (DOCS / "SUMMARY.html").write_text(render_summary_html(entries, files, control_defs, search_index), encoding="utf-8")
    print(f"Generated {len(entries)} entries from {len(files)} IPF files")


if __name__ == "__main__":
    main()
