import KoreApp from './kore/agents/kore-app.js';

export class GitViewer extends KoreApp {
  constructor(settings) {
    super(settings);
    this.projectPath = settings.projectPath;
  }

  init() {
    this.addLayer({
      handleEvent: (e) => {
        if (e.type == 'keydown') {
          if (e.key == 'Space') {

            //return true;
          }
          if (e.key == 'Tab') {
            //return true;
          }
        }
      }
    });

    this.addLayer({
      render: (canvas, ctx, progress) => {
          ctx.fillStyle = '#fff';
        if (this.data) {
            ctx.fillText(this.data.authors.length.toString(), 100, 100);
        } else {
            ctx.fillText('loading', 100, 100);
        }
      }
    });

    this.layout.refresh();

    const app = this;

    $.get( `/data/git_log/${this.projectPath}` ).done(function( data ) {

        const uq = (value, index, self) => {
            return self.indexOf(value) === index;
        }
        app.data = data;
        app.data.authors = data.commits.map(c => c.author).filter(uq)
        app.data.files = data.commits.map(c => (c.files ? c.files : []).map(f => f.path)).reduce((f1, f2) => f1.concat(f2), []).filter(uq)
        app.data.directories = app.data.files.map(f => {
            const parts = f.split("/");
            const dirs = parts.map((p, i) => {
                return [...Array(i).keys()].map(n => parts[n]).join("/");
            });
            return dirs;
        }).reduce((f1, f2) => f1.concat(f2), []).filter(uq);

        const app_ruby_files = app.data.files.filter(f => (f.startsWith('./app/') || f.startsWith('./lib/')) && f.endsWith('.rb'));
        app.data.app_ruby_files = app_ruby_files;
        console.log(app.data);

    });
  }
}


/*
  - directory structure
   - patterns

  - File connectivity
    - by structure / path
    - by content
    - by commits
*/