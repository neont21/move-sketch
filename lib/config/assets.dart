abstract final class Assets {
  // 공통 / 기본 에셋
  static const String sampleSketch = 'assets/sample_sketch.png';
  static const String logoMark = 'assets/brand/logo-mark.svg';
  static const String partsDir = 'assets/parts';

  // TODO: Mock 데이터 정리 후 삭제 예정
  static const String defaultProfile = 'assets/default_profile.png';

  // 배경 파츠
  static const String bgDefault = 'assets/parts/bg_default.png';
  static const String bgParkDay = 'assets/parts/bg_park_day.png';
  static const String bgRiverSunset = 'assets/parts/bg_river_sunset.png';
  static const String bgCityNight = 'assets/parts/bg_city_night.png';
  static const String bgHangangTrack = 'assets/parts/bg_hangang_track.png';
  static const String bgCoastalRoad = 'assets/parts/bg_coastal_road.png';
  static const String bgMountainPass = 'assets/parts/bg_mountain_pass.png';

  // 기본 캐릭터 파츠
  static const String characterBear = 'assets/parts/character_bear_basic.png';
  static const String characterCat = 'assets/parts/character_cat_basic.png';
  static const String characterDog = 'assets/parts/character_dog_basic.png';
  static const String characterPanda = 'assets/parts/character_panda_basic.png';

  // 의상 파츠
  static const String costumeSportT1 = 'assets/parts/costume_sport_t1.png';
  static const String costumeSportT2 = 'assets/parts/costume_sport_t2.png';
  static const String costumeSportT3 = 'assets/parts/costume_sport_t3.png';
  static const String costumeJerseyT1 = 'assets/parts/costume_jersey_t1.png';
  static const String costumeJerseyT2 = 'assets/parts/costume_jersey_t2.png';
  static const String costumeJerseyT3 = 'assets/parts/costume_jersey_t3.png';

  // 표정 파츠
  static const String exprDefault = 'assets/parts/expr_default.png';
  static const String exprSmile = 'assets/parts/expr_smile.png';
  static const String exprEnergetic = 'assets/parts/expr_energetic.png';
  static const String exprProud = 'assets/parts/expr_proud.png';
  static const String exprRelaxed = 'assets/parts/expr_relaxed.png';
  static const String exprConfident = 'assets/parts/expr_confident.png';
  static const String exprThrilled = 'assets/parts/expr_thrilled.png';

  // 소품 파츠
  static const String propWaterBottle = 'assets/parts/prop_water_bottle.png';
  static const String propCamera = 'assets/parts/prop_camera.png';
  static const String propExplorerFlag = 'assets/parts/prop_explorer_flag.png';
  static const String propHelmetLight = 'assets/parts/prop_helmet_light.png';
  static const String propCyclocomputer = 'assets/parts/prop_cyclocomputer.png';
  static const String propPannierBag = 'assets/parts/prop_pannier_bag.png';

  // 효과 파츠
  static const String effectBreeze = 'assets/parts/effect_breeze.png';
  static const String effectSparkle = 'assets/parts/effect_sparkle.png';
  static const String effectFireBoost = 'assets/parts/effect_fire_boost.png';
  static const String effectWindLines = 'assets/parts/effect_wind_lines.png';
  static const String effectLightningTrail =
      'assets/parts/effect_lightning_trail.png';
  static const String effectSupersonic = 'assets/parts/effect_supersonic.png';

  // 기본형 캐릭터
  static const String defaultCharacterBear = 'assets/characters/default_bear.png';
  static const String defaultCharacterCat = 'assets/characters/default_cat.png';
  static const String defaultCharacterDog = 'assets/characters/default_dog.png';
  static const String defaultCharacterPanda = 'assets/characters/default_panda.png';

  // 동적 경로 헬퍼
  static String character(String id) =>
      'assets/parts/character_${id.toLowerCase()}_basic.png';
  static String defaultCharacter(String id) =>
      'assets/characters/default_${id.toLowerCase()}.png';
  static String part(String filename) => 'assets/parts/$filename';
}
