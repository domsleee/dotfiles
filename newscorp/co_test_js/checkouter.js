const Git = require('nodegit');
const path = require('path');

class Checkouter {
  constructor(branch, plugins_folder, force) {
    this.branch = branch;
    this.plugins_folder = plugins_folder;
    this.force = force;
  }

  async checkout_branch(plugin_name) {
    let filepath = path.join(this.plugins_folder, plugin_name);
    let repo = await Git.Repository.open(filepath);
    let status = await repo.getStatus();
    let branch = this.branch;
    if (status.length > 0) {
      console.log(plugin_name, status.length);
      let index = await repo.index();
      index.addAll();
      if (this.force || this._only_phpcs(status)) {
        if (this.force) {
          console.log(`${plugin_name}: Force, not stashing...`);
        } else {
          console.log(`${plugin_name}: only phpunit/phpcs`);
        }
      } else {
        console.log(`stash ${plugin_name}`);
        let sig = Git.Signature.now('hi', 'there@there.com');
        await Git.Stash.save(repo, sig, 'created by co_test.js', 0);
      }
      //await Git.Reset.default(repo, branch, Git.Reset.TYPE.HARD);
    }

    let branchRef = await repo.getCurrentBranch();
    //Git.Branch.setUpstream(branchRef, `origin/${branch}`);
    await this._checkoutRemoteBranch(repo, branch);

    

    await repo.fetchAll({
      callbacks: {
        credentials: function(url, userName) {
          return Git.Cred.sshKeyNew(
            userName,
            SSH_PUB,
            SSH_KEY,
            "");
        },
        certificateCheck: function() {
          return 1;
        }
      }
    });
    await repo.mergeBranches(branch, `origin/${branch}`);
    console.log("merged??")
    
    //console.log(plugin_name, status);
  }

  async _checkoutRemoteBranch(repo, remoteBranchName) {
    let targetCommit = await repo.getHeadCommit()
    //let reference = await repo.createBranch(remoteBranchName, targetCommit, false);
    let reference = await repo.getBranch(remoteBranchName);
    await repo.checkoutBranch(reference, {});
    let commit = await repo.getReferenceCommit(
        "refs/remotes/origin/" + remoteBranchName);
    await Git.Reset.reset(repo, commit, 3, {});
  }

  _only_phpcs(status) {
    for (let stat of status) {
      let p = stat.path();
      if (p == 'phpunit.xml' || p == 'phpcs.ruleset.xml' || p == 'phpunit-bootstrap.php') continue;
      return false;
    }
    return true;
  }
}

module.exports = {
  Checkouter: Checkouter
};