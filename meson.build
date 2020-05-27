project(
    'xplaces',
    'vala', 'c',
    version: '1.0.0'
)

gnome = import('gnome')
i18n = import('i18n')
gettext_name = meson.project_name() + '-indicator'

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(gettext_name), language:'c')

wingpanel_dep = dependency('wingpanel-2.0')

subdir('data')

shared_module(
    meson.project_name(),
    'src/Indicator.vala',
    'src/Widgets/BookmarksItem.vala',
    'src/Widgets/ListItem.vala',
    'src/Widgets/MountItem.vala',
    'src/Widgets/Popover.vala',
    'src/Widgets/VolumeItem.vala',
    gresource,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('granite'),
        dependency('gtk+-3.0'),
        wingpanel_dep
    ],
    install: true,
    install_dir : wingpanel_dep.get_pkgconfig_variable('indicatorsdir')
)

subdir('po')
