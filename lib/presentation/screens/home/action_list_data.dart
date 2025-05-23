class ActionListData {
  ActionListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = '',
    this.endColor = '',
    this.actions,
  });

  String imagePath;
  String titleTxt;
  String startColor;
  String endColor;
  List<String>? actions;

  static List<ActionListData> tabIconsList = <ActionListData>[
    ActionListData(
      imagePath: 'assets/fitness_app/recycle.png',
      titleTxt: 'Recycle',
      actions: <String>['Products,', 'RetuRO'],
      startColor: '#94A885',
      endColor: '#72B794',
    ),
    ActionListData(
      imagePath: 'assets/fitness_app/working-at-home.png',
      titleTxt: 'Work',
      actions: <String>['Remote,', 'Office'],
      startColor: '#738AE6',
      endColor: '#5C5EDD',
    ),
    ActionListData(
      imagePath: 'assets/fitness_app/challenge.png',
      titleTxt: 'Challenges',
      actions: <String>['Join,', 'Give up'],
      startColor: '#FFC53C',
      endColor: '#FF9200',
    ),
    ActionListData(
      imagePath: 'assets/fitness_app/info.png',
      titleTxt: 'Info',
      actions: <String>['Waste', 'Management'],
      startColor: '#FE95B6',
      endColor: '#FF5287',
    ),
  ];
}
