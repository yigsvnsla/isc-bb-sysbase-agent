const sidebars = {
  mainSidebar: [
    'intro',
    {
      type: 'category',
      label: 'Procedimientos Almacenados',
      link: { type: 'doc', id: 'procedimientos/index' },
      items: [],
    },
    {
      type: 'category',
      label: 'Esquemas',
      link: { type: 'doc', id: 'esquemas/index' },
      items: [],
    },
    {
      type: 'category',
      label: 'Migraciones',
      link: { type: 'doc', id: 'migraciones/index' },
      items: [],
    },
    {
      type: 'category',
      label: 'Estándares',
      link: { type: 'doc', id: 'estandares/index' },
      items: [
        'estandares/sybase-sqlserver',
        'estandares/oracle',
        'estandares/anexos',
        'estandares/control-cambios',
      ],
    },
    {
      type: 'category',
      label: 'Diagramas',
      link: { type: 'doc', id: 'diagramas/index' },
      items: [],
    },
  ],
};

module.exports = sidebars;
