class NoteToSelf < Formula
  desc "Chat with yourself in a local app that saves every note as Markdown"
  homepage "https://github.com/human-genomics/note-to-self"
  url "https://github.com/human-genomics/note-to-self/releases/download/v0.1.0/note-to-self-0.1.0.tar.gz"
  sha256 "cc692a1db54d1c5c7494ba43934847278d1c31ca0a909f9175b4b22fa57b3413"
  license "MIT"
  head "https://github.com/human-genomics/note-to-self.git", branch: "main"

  depends_on "python@3.14"

  def install
    libexec.install "notetoself.py", "nts", "web"
    (bin/"notetoself").write <<~SH
      #!/bin/sh
      exec "#{formula_opt_bin("python@3.14")}/python3.14" "#{libexec}/notetoself.py" "$@"
    SH
  end

  def caveats
    <<~EOS
      To open Note to Self like any other app (from Launchpad, Spotlight or the
      Dock), add it to your Applications folder once:
        notetoself --install-app
      Or run `notetoself` in a terminal. Your notes are saved in ~/NoteToSelf.
      Uninstalling doesn't delete them: use Settings > Delete all data first if
      you want them gone.
    EOS
  end

  test do
    port = free_port
    notes = testpath/"notes"
    pid = spawn bin/"notetoself", "--no-open", "--port", port.to_s, "--dir", notes
    begin
      sleep 3
      ping = shell_output("curl -s -H 'X-NoteToSelf: 1' http://127.0.0.1:#{port}/api/ping")
      assert_match '"app":"note-to-self"', ping
      assert_path_exists notes/"Note to Self"
      assert_path_exists notes/".notetoself.json"
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
