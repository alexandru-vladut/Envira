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
      imagePath: 'assets/images/home/recycle.png',
      titleTxt: 'Recycle',
      actions: <String>['Locations,', 'Products'],
      startColor: '#52D980',
      endColor: '#2DA757',
    ),
    ActionListData(
      imagePath: 'assets/images/home/working-at-home.png',
      titleTxt: 'Work',
      actions: <String>['Remote,', 'Office'],
      startColor: '#3881E0',
      endColor: '#6C5CE7',
    ),
    ActionListData(
      imagePath: 'assets/images/home/challenge.png',
      titleTxt: 'Challenges',
      actions: <String>['Join,', 'Give up'],
      startColor: '#FFC53C',
      endColor: '#FF9200',
    ),
    ActionListData(
      imagePath: 'assets/images/home/info.png',
      titleTxt: 'Info',
      actions: <String>['Waste', 'Management'],
      startColor: '#FE95B6',
      endColor: '#FF5287',
    ),
  ];
}
