
export default function (kibana) {
  return new kibana.Plugin({
   uiExports: {
     app: {
        title: 'rwi_style',
        order: -100,
        description: 'Gradiant Styling',
        main: 'plugins/rwi_style/index.js',
        hidden: true
     }
    }
  });
};
