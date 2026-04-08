// Small TUI: open GitHub PRs (gh) + recent Cursor agent transcript sessions.
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type prEntry struct {
	repo    string
	number  int
	title   string
	url     string
	updated time.Time
}

func (p prEntry) Title() string {
	return truncate(fmt.Sprintf("%s #%d  %s", p.repo, p.number, p.title), 78)
}

func (p prEntry) Description() string {
	return fmt.Sprintf("%s · %s", p.updated.Local().Format("Jan 2  15:04"), p.url)
}

func (p prEntry) FilterValue() string { return p.title + p.repo }

type sessEntry struct {
	workspace string
	preview   string
	path      string
	modTime   time.Time
}

func (s sessEntry) Title() string {
	return truncate(s.workspace+" — "+s.preview, 82)
}

func (s sessEntry) Description() string {
	return fmt.Sprintf("%s · %s", s.modTime.Local().Format("Jan 2  15:04"), s.path)
}

func (s sessEntry) FilterValue() string { return s.preview + s.workspace }

type refreshMsg struct {
	prItems     []list.Item
	prErr       string
	sessItems   []list.Item // all recent sessions
	sessPRItems []list.Item // sessions whose transcript mentions an open PR URL
	sessErr     string
}

type model struct {
	tab          int // 0 PRs, 1 sessions
	prList       list.Model
	sessList     list.Model
	prErr        string
	sessErr      string
	sessFilterPR bool // sessions tab: only show transcripts that reference a listed open PR
	sessAllItems []list.Item
	sessPRItems  []list.Item
	width        int
	height       int
}

var (
	styleTitle  = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("4"))
	styleTab    = lipgloss.NewStyle().Foreground(lipgloss.Color("8"))
	styleTabSel = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("6"))
	styleFooter = lipgloss.NewStyle().Foreground(lipgloss.Color("8"))
	styleErr    = lipgloss.NewStyle().Foreground(lipgloss.Color("9"))
	styleSubtle = lipgloss.NewStyle().Foreground(lipgloss.Color("8"))
)

func main() {
	m := newModel()
	p := tea.NewProgram(m, tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func newModel() *model {
	d := list.NewDefaultDelegate()
	d.ShowDescription = true
	d.SetSpacing(1)

	pr := list.New([]list.Item{}, d, 80, 20)
	pr.SetShowTitle(false)
	pr.SetShowStatusBar(true)
	pr.SetFilteringEnabled(false)
	pr.DisableQuitKeybindings()

	sess := list.New([]list.Item{}, d, 80, 20)
	sess.SetShowTitle(false)
	sess.SetShowStatusBar(true)
	sess.SetFilteringEnabled(false)
	sess.DisableQuitKeybindings()

	return &model{
		prList:   pr,
		sessList: sess,
		width:    80,
		height:   24,
	}
}

func (m *model) Init() tea.Cmd {
	return refreshCmd
}

func refreshCmd() tea.Msg {
	prItems, prErr := loadPRs()
	sessAll, sessPR, sessErr := loadSessions(prItems)
	return refreshMsg{
		prItems:     prItems,
		prErr:       prErr,
		sessItems:   sessAll,
		sessPRItems: sessPR,
		sessErr:     sessErr,
	}
}

func (m *model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
		h := msg.Height - 6
		if h < 4 {
			h = 4
		}
		m.prList.SetSize(msg.Width, h)
		m.sessList.SetSize(msg.Width, h)
		return m, nil

	case refreshMsg:
		m.prErr = msg.prErr
		m.sessErr = msg.sessErr
		m.prList.SetItems(msg.prItems)
		m.sessAllItems = msg.sessItems
		m.sessPRItems = msg.sessPRItems
		m.applySessionFilter()
		return m, nil

	case tea.KeyMsg:
		switch msg.String() {
		case "ctrl+c", "q":
			return m, tea.Quit
		case "r":
			return m, refreshCmd
		case "p":
			if m.tab == 1 {
				m.sessFilterPR = !m.sessFilterPR
				m.applySessionFilter()
			}
			return m, nil
		case "tab", "right", "l":
			m.tab = 1
			return m, nil
		case "shift+tab", "left", "h":
			m.tab = 0
			return m, nil
		case "1":
			m.tab = 0
			return m, nil
		case "2":
			m.tab = 1
			return m, nil
		case "o":
			m.openSelected()
			return m, nil
		}
	}

	var cmd tea.Cmd
	if m.tab == 0 {
		m.prList, cmd = m.prList.Update(msg)
	} else {
		m.sessList, cmd = m.sessList.Update(msg)
	}
	return m, cmd
}

func (m *model) applySessionFilter() {
	if m.sessFilterPR {
		m.sessList.SetItems(m.sessPRItems)
	} else {
		m.sessList.SetItems(m.sessAllItems)
	}
}

func (m *model) openSelected() {
	if m.tab == 0 {
		i, ok := m.prList.SelectedItem().(prEntry)
		if !ok || i.url == "" {
			return
		}
		_ = exec.Command("open", i.url).Start()
		return
	}
	i, ok := m.sessList.SelectedItem().(sessEntry)
	if !ok || i.path == "" {
		return
	}
	_ = exec.Command("open", "-R", i.path).Start()
}

func (m *model) View() string {
	tab1 := styleTab.Render(" 1 PRs ")
	if m.tab == 0 {
		tab1 = styleTabSel.Render(" 1 PRs ")
	}
	sessLabel := " 2 Sessions "
	if m.sessFilterPR && m.tab == 1 {
		sessLabel = " 2 Sessions (PR-linked) "
	}
	tab2 := styleTab.Render(sessLabel)
	if m.tab == 1 {
		tab2 = styleTabSel.Render(sessLabel)
	}
	header := lipgloss.JoinHorizontal(lipgloss.Top,
		styleTitle.Render("PRs & agent sessions"),
		styleSubtle.Render("   "),
		tab1,
		tab2,
	)

	errLine := ""
	if m.tab == 0 && m.prErr != "" {
		errLine = styleErr.Render("GitHub: "+m.prErr) + "\n"
	} else if m.tab == 1 && m.sessErr != "" {
		errLine = styleErr.Render("Sessions: "+m.sessErr) + "\n"
	}

	body := m.prList.View()
	if m.tab == 1 {
		body = m.sessList.View()
	}

	footer := styleFooter.Render(
		"tab / 1·2 switch   p PR-linked sessions (on tab 2)   j/k move   o open   r refresh   q quit",
	)

	return lipgloss.JoinVertical(lipgloss.Left,
		header,
		errLine,
		body,
		footer,
	)
}

// GraphQL search returns private org PRs; `gh search prs --owner <user>` only
// covers personal repos and misses most org-owned work.
const gqlSearchPRs = `query($q: String!) {
  search(query: $q, type: ISSUE, first: 100) {
    nodes {
      ... on PullRequest {
        number
        title
        url
        updatedAt
        repository { nameWithOwner }
      }
    }
  }
}`

type gqlPRNode struct {
	Number     int    `json:"number"`
	Title      string `json:"title"`
	URL        string `json:"url"`
	UpdatedAt  string `json:"updatedAt"`
	Repository struct {
		NameWithOwner string `json:"nameWithOwner"`
	} `json:"repository"`
}

type gqlSearchResponse struct {
	Data struct {
		Search struct {
			Nodes []*gqlPRNode `json:"nodes"`
		} `json:"search"`
	} `json:"data"`
	Errors []struct {
		Message string `json:"message"`
	} `json:"errors"`
}

func loadPRs() ([]list.Item, string) {
	if _, err := exec.LookPath("gh"); err != nil {
		return nil, "gh not in PATH"
	}
	login, err := ghLogin()
	if err != nil {
		return nil, err.Error()
	}
	queries := []string{
		fmt.Sprintf("is:open involves:%s", login),
		fmt.Sprintf("is:open review-requested:%s", login),
	}
	seen := make(map[string]struct{})
	var rows []gqlPRNode
	var errMsgs []string
	for _, q := range queries {
		nodes, qerr := graphqlSearchPRs(q)
		if qerr != nil {
			errMsgs = append(errMsgs, qerr.Error())
			continue
		}
		for _, n := range nodes {
			if n == nil || n.URL == "" {
				continue
			}
			if _, ok := seen[n.URL]; ok {
				continue
			}
			seen[n.URL] = struct{}{}
			rows = append(rows, *n)
		}
	}
	if len(rows) == 0 && len(errMsgs) > 0 {
		return nil, strings.Join(errMsgs, "; ")
	}
	sort.Slice(rows, func(i, j int) bool {
		ti, _ := time.Parse(time.RFC3339, rows[i].UpdatedAt)
		tj, _ := time.Parse(time.RFC3339, rows[j].UpdatedAt)
		return ti.After(tj)
	})
	items := make([]list.Item, 0, len(rows))
	for _, r := range rows {
		t, _ := time.Parse(time.RFC3339, r.UpdatedAt)
		items = append(items, prEntry{
			repo:    r.Repository.NameWithOwner,
			number:  r.Number,
			title:   r.Title,
			url:     r.URL,
			updated: t,
		})
	}
	return items, ""
}

func graphqlSearchPRs(searchQuery string) ([]*gqlPRNode, error) {
	cmd := exec.Command(
		"gh", "api", "graphql",
		"-f", "query="+gqlSearchPRs,
		"-f", "q="+searchQuery,
	)
	out, err := cmd.Output()
	if err != nil {
		if ee, ok := err.(*exec.ExitError); ok {
			return nil, fmt.Errorf("%s", strings.TrimSpace(string(ee.Stderr)))
		}
		return nil, err
	}
	var resp gqlSearchResponse
	if err := json.Unmarshal(out, &resp); err != nil {
		return nil, err
	}
	if len(resp.Errors) > 0 {
		var b strings.Builder
		for _, e := range resp.Errors {
			b.WriteString(e.Message)
			b.WriteString("; ")
		}
		return nil, fmt.Errorf("%s", strings.TrimSuffix(b.String(), "; "))
	}
	return resp.Data.Search.Nodes, nil
}

func ghLogin() (string, error) {
	out, err := exec.Command("gh", "api", "user", "-q", ".login").Output()
	if err != nil {
		return "", fmt.Errorf("gh auth: %w", err)
	}
	return strings.TrimSpace(string(out)), nil
}

const maxTranscriptBytes = 8 << 20 // 8 MiB per file

// loadSessions scans Cursor agent transcripts. prItems is used to build URL
// substrings to match; sessions whose file content mentions any open PR URL
// are included in the PR-linked list (up to 60, by mtime).
func loadSessions(prItems []list.Item) (all []list.Item, prOnly []list.Item, errStr string) {
	keys := prMatchKeySet(prItems)
	home, err := os.UserHomeDir()
	if err != nil {
		return nil, nil, err.Error()
	}
	root := filepath.Join(home, ".cursor", "projects")
	fi, err := os.Stat(root)
	if err != nil || !fi.IsDir() {
		return nil, nil, "~/.cursor/projects not found"
	}
	type found struct {
		path string
		t    time.Time
	}
	var paths []found
	_ = filepath.Walk(root, func(path string, info os.FileInfo, err error) error {
		if err != nil || info.IsDir() {
			return nil
		}
		if !strings.HasSuffix(path, ".jsonl") {
			return nil
		}
		if strings.Contains(path, string(filepath.Separator)+"subagents"+string(filepath.Separator)) {
			return nil
		}
		rel, err := filepath.Rel(root, path)
		if err != nil {
			return nil
		}
		parts := strings.Split(rel, string(filepath.Separator))
		if len(parts) != 4 || parts[1] != "agent-transcripts" {
			return nil
		}
		if parts[2] != strings.TrimSuffix(parts[3], ".jsonl") {
			return nil
		}
		paths = append(paths, found{path: path, t: info.ModTime()})
		return nil
	})
	sort.Slice(paths, func(i, j int) bool { return paths[i].t.After(paths[j].t) })

	type scanned struct {
		entry   sessEntry
		prMatch bool
	}
	var out []scanned
	for _, f := range paths {
		data, err := readFileLimited(f.path, maxTranscriptBytes)
		if err != nil || len(data) == 0 {
			continue
		}
		rel, _ := filepath.Rel(root, f.path)
		parts := strings.Split(rel, string(filepath.Separator))
		ws := parts[0]
		preview := firstUserPreviewFromBytes(data)
		e := sessEntry{
			workspace: ws,
			preview:   preview,
			path:      f.path,
			modTime:   f.t,
		}
		out = append(out, scanned{
			entry:   e,
			prMatch: dataMentionsPR(data, keys),
		})
	}

	n := 60
	if len(out) < n {
		n = len(out)
	}
	all = make([]list.Item, 0, n)
	for i := 0; i < n; i++ {
		all = append(all, out[i].entry)
	}

	var prMatches []sessEntry
	for _, s := range out {
		if s.prMatch {
			prMatches = append(prMatches, s.entry)
			if len(prMatches) >= 60 {
				break
			}
		}
	}
	prOnly = make([]list.Item, len(prMatches))
	for i := range prMatches {
		prOnly[i] = prMatches[i]
	}
	return all, prOnly, ""
}

func prMatchKeySet(prItems []list.Item) map[string]struct{} {
	keys := make(map[string]struct{})
	for _, it := range prItems {
		p, ok := it.(prEntry)
		if !ok || p.url == "" {
			continue
		}
		u := strings.TrimSpace(p.url)
		if i := strings.Index(u, "?"); i >= 0 {
			u = u[:i]
		}
		u = strings.TrimSuffix(u, "/")
		low := strings.ToLower(u)
		keys[low] = struct{}{}
		if idx := strings.Index(low, "github.com/"); idx >= 0 {
			keys[low[idx:]] = struct{}{}
		}
		// Markdown / chat short form: org/repo#123
		short := strings.ToLower(fmt.Sprintf("%s#%d", p.repo, p.number))
		keys[short] = struct{}{}
	}
	return keys
}

func dataMentionsPR(data []byte, keys map[string]struct{}) bool {
	if len(keys) == 0 {
		return false
	}
	s := normalizeForPRMatch(data)
	for k := range keys {
		if k == "" {
			continue
		}
		if strings.Contains(s, k) {
			return true
		}
	}
	return false
}

// normalizeForPRMatch lowercases and fixes JSON-escaped slashes so URLs in
// tool payloads (e.g. https:\/\/github.com\/...) still match.
func normalizeForPRMatch(data []byte) string {
	s := string(data)
	s = strings.ReplaceAll(s, `\/`, `/`)
	s = strings.ReplaceAll(s, `\u002f`, `/`)
	return strings.ToLower(s)
}

func readFileLimited(path string, max int) ([]byte, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	return io.ReadAll(io.LimitReader(f, int64(max)))
}

func firstUserPreviewFromBytes(data []byte) string {
	line := firstLine(data)
	line = strings.TrimSpace(line)
	if line == "" {
		return "(empty)"
	}
	var payload struct {
		Role    string `json:"role"`
		Message struct {
			Content []struct {
				Type string `json:"type"`
				Text string `json:"text"`
			} `json:"content"`
		} `json:"message"`
	}
	if err := json.Unmarshal([]byte(line), &payload); err != nil {
		return truncate(line, 70)
	}
	var b strings.Builder
	for _, c := range payload.Message.Content {
		if c.Text != "" {
			b.WriteString(c.Text)
		}
	}
	text := strings.TrimSpace(b.String())
	text = stripUserQuery(text)
	text = strings.ReplaceAll(text, "\n", " ")
	return truncate(text, 72)
}

func firstLine(data []byte) string {
	idx := bytes.IndexByte(data, '\n')
	if idx < 0 {
		return string(data)
	}
	return string(data[:idx])
}

func stripUserQuery(s string) string {
	const open = "<user_query>"
	const close = "</user_query>"
	i := strings.Index(s, open)
	j := strings.Index(s, close)
	if i >= 0 && j > i {
		return strings.TrimSpace(s[i+len(open) : j])
	}
	return s
}

func truncate(s string, max int) string {
	r := []rune(strings.TrimSpace(s))
	if len(r) <= max {
		return string(r)
	}
	return string(r[:max-1]) + "…"
}
