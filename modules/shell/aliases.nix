{
  flake.modules.homeManager.base.home.shellAliases = {
    # Ask before overwriting; rm asks once for more than three files or a directory.
    cp = "cp -iv";
    mv = "mv -iv";
    rm = "rm -vI";
    mkd = "mkdir -pv";

    grep = "grep --color=auto";
    diff = "diff --color=auto";

    # sudo not required for these
    mount = "sudo mount";
    umount = "sudo umount";
    su = "sudo su";

    ka = "killall";
    g = "git";
    v = "$EDITOR";

    # Git, from oh-my-zsh's git plugin.
    gst = "git status";
    gss = "git status --short";
    gsb = "git status --short --branch";
    ga = "git add";
    gaa = "git add --all";
    gapa = "git add --patch";
    gd = "git diff";
    gds = "git diff --staged";
    gc = "git commit --verbose";
    "gc!" = "git commit --verbose --amend";
    gca = "git commit --verbose --all";
    gcmsg = "git commit --message";
    gsh = "git show";
    gb = "git branch";
    gba = "git branch --all";
    gbd = "git branch --delete";
    gsw = "git switch";
    gswc = "git switch --create";
    gco = "git checkout";
    gcb = "git checkout -b";
    gf = "git fetch";
    gl = "git pull";
    gpr = "git pull --rebase";
    gp = "git push";
    gpf = "git push --force-with-lease --force-if-includes";
    gcl = "git clone --recurse-submodules";
    glo = "git log --oneline --decorate";
    glog = "git log --oneline --decorate --graph";
    gloga = "git log --oneline --decorate --graph --all";
    grb = "git rebase";
    grbi = "git rebase --interactive";
    grbc = "git rebase --continue";
    grba = "git rebase --abort";
    gm = "git merge";
    gcp = "git cherry-pick";
    gsta = "git stash push";
    gstp = "git stash pop";
    gstl = "git stash list";
    grs = "git restore";
    grst = "git restore --staged";
    grh = "git reset";
    grhh = "git reset --hard";
  };
}
