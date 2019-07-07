const assert = require('assert');
const { spawn, execSync } = require('child_process');
const TEST_REPO = 'ssh://git@stash.news.com.au/spp/plugin-spp-sitemap.git';
const TEST_FOLDER = '/tmp/testo';
const path = require('path');
const TEST_REPO_FOLDER = path.join(TEST_FOLDER, 'test');
const fs = require('fs-extra');
const Checkouter = require('../checkouter').Checkouter;

describe('basic tests', function() {
  beforeEach(async function() {
    this.timeout(10*1000);
    if (fs.pathExistsSync(TEST_FOLDER)) {
      fs.removeSync(TEST_FOLDER);
    }
    fs.mkdirpSync(TEST_FOLDER);
    execSync(`git clone "${TEST_REPO}" "${TEST_REPO_FOLDER}"`);
  });

  it('non-committed file should be stashed', async () => {
    execSync(`touch "${TEST_FOLDER}/a"`);
    let co = new Checkouter('test', TEST_FOLDER, false);
    await co.checkout_branch('test');
    assert(false);
  });

  it('added file should be stashed', async () => {
    execSync(`touch "${TEST_REPO_FOLDER}/a"`);
    execSync(`git -C "${TEST_REPO_FOLDER}" add a`);
    let co = new Checkouter('test', TEST_FOLDER, false);
    await co.checkout_branch('test');
    assert(false);
  });
});