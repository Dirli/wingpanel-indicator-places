install_data('10-enable-mount.rules',
    install_mode: 'rw-r--r--',
    install_dir: join_paths(get_option('datadir'), 'polkit-1', 'rules.d')
)

gresource = gnome.compile_resources(
    'as-resources',
    join_paths(meson.project_name() + '.gresource.xml'),
    source_dir: 'data',
    c_name: 'as'
)
