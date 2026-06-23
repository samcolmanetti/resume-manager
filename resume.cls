%% resume.cls: minimal, ATS-friendly one-page resume class
%% All formatting lives here. Content files use the semantic macros below.
%% Build with xelatex (uses the system Charter font via fontspec).
%% Dependencies are limited to packages shipped with BasicTeX (no tlmgr installs needed).
%%
%% --- Extending: adding new section macros ---------------------------------
%% All formatting (spacing, fonts, layout) must live in this file.
%% Content files (resume-NAME.tex) use only the semantic macros defined here;
%% never add \vspace, \fontsize, or \textbf directly in a content file.
%%
%% To add a new entry type, define a new \newcommand or \newenvironment here
%% and reference it from your content file. Example pattern:
%%
%%   % \award{Title}{Organization}{Year}
%%   \newcommand{\award}[3]{\vspace{2pt}\noindent\textbf{#1}, #2\hfill #3\par}
%%
%% Keep new macros consistent with the spacing used by \oneline and \entry.
%% --------------------------------------------------------------------------
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{resume}[2026/06/01 v1 Minimal one-page resume]

% Pass an optional base font size (bare pt numbers). Default 10/11.8.
\newcommand{\resume@ptsize}{10}
\newcommand{\resume@leading}{11.8}
\DeclareOption{11pt}{\renewcommand{\resume@ptsize}{11}\renewcommand{\resume@leading}{13}}
\DeclareOption{10pt}{\renewcommand{\resume@ptsize}{10}\renewcommand{\resume@leading}{11.8}}
\DeclareOption{10.5pt}{\renewcommand{\resume@ptsize}{10.5}\renewcommand{\resume@leading}{12.4}}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass[letterpaper]{article}

\RequirePackage[letterpaper,top=0.45in,bottom=0.45in,left=0.5in,right=0.5in]{geometry}
\RequirePackage{fontspec}
\RequirePackage{xcolor}
\RequirePackage[hidelinks]{hyperref}

% --- Font: Charter (system font, clean + ATS-safe). Base size set here. ---
\setmainfont{Charter}
\renewcommand{\normalsize}{\fontsize{\resume@ptsize}{\resume@leading}\selectfont}
\normalsize

% --- Page setup ---
\pagestyle{empty}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}

% --- Section headings: bold uppercase + full-width rule, tight spacing ---
% Custom (no titlesec dependency). Charter has no bold small-caps shape, so use
% bold uppercase, which is strong and ATS-safe.
\renewcommand{\section}[1]{%
  \par\vspace{7.5pt}%
  {\normalfont\bfseries\fontsize{11.5}{13}\selectfont\MakeUppercase{#1}}\par
  \vspace{1pt}\hrule height 0.6pt\vspace{3pt}}

% --- Header macros (tight centering: no trivlist padding, explicit gaps) ---
% \name{Full Name}
\newcommand{\name}[1]{{\centering\fontsize{19pt}{21pt}\selectfont\bfseries #1\par}\vspace{2pt}}
% \location{City, ST} — optional centered line directly under the name
\newcommand{\location}[1]{{\centering\small #1\par}}
% \contact{a \sep b \sep c}
\newcommand{\contact}[1]{{\centering\small #1\par}\vspace{2pt}}
\newcommand{\sep}{\quad\textbar\quad}

% --- Tight "++" so "C++" doesn't render with a gap between the plus signs ---
\newcommand{\pp}{\kern-0.05em+\kern-0.11em+}

% --- Experience / entry header: \entry{Left bold (role, company, location)}{Right (dates)} ---
\newcommand{\entry}[2]{\vspace{4pt}\noindent\textbf{#1}\hfill #2\par\vspace{1.5pt}}

% --- Education entry: \edu{School}{Right1}{Degree line}{Right2} ---
\newcommand{\edu}[4]{\vspace{4pt}\noindent\textbf{#1}\hfill #2\par\noindent #3\hfill #4\par}

% --- Skills line: \skill{Label}{values} ---
\newcommand{\skill}[2]{\noindent\textbf{#1:} #2\par\vspace{1pt}}

% --- One-line entry (no bullets): \oneline{Left}{Right} ---
\newcommand{\oneline}[2]{\vspace{2pt}\noindent #1\hfill #2\par}

% --- Bullets: compact list (no enumitem dependency) ---
\newenvironment{bullets}{%
  \begin{list}{\textbullet}{%
    \setlength{\topsep}{1pt}%
    \setlength{\partopsep}{0pt}%
    \setlength{\parsep}{0pt}%
    \setlength{\itemsep}{1pt}%
    \setlength{\leftmargin}{1.25em}%
    \setlength{\labelwidth}{0.75em}%
    \setlength{\labelsep}{0.5em}%
    \setlength{\rightmargin}{0pt}%
  }}{\end{list}}

\endinput
