import '../../features/onboarding/domain/models/language_option.dart';

class LanguageConstants {
  static const List<LanguageOption> targetLanguages = [
    LanguageOption(
      name: 'English',
      subtitle: 'Hello',
      flagUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB3o9h13vMUw0UlVF3KGfZ_GibGHgDzzI4cUYybLts9J2ZrM8v006e9A91nnplDP4TBmu3C3cqbGG_SVG9wtG1UOXqklHUUFdWGvvQ0dcqlXLHrdLIytG6I2HE4zRadCKpOYm_vnjXgc4DIa5eRfJvlC9HbTicodMY7fVXJ93LD2S2H-biRrfFoG5-Au1SxC-BoYcLpdhL81FI45PfguWBJA8onzM3ePPF-JKLk9BMiJuOzaOAdzZmf0sxNzHvyGJ3dQYggEf4GRpk',
      code: 'en',
      available: true,
    ),
    LanguageOption(
      name: 'Chinese',
      subtitle: '你好',
      flagUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBp76FMK1clf0RSjXXjSEP95JDYe7KyWPLzeHN8o9ki1b5iIhdWF_JV9SEvdQxnlKoq7Wg07mSuPWs8auuEdQih_4fvjALgMWGsUXRSQ6TzAm0nCZDwX54-VIh0-Hns4nlTcrihwbKo4jKQakgkY90miEKt6ATzZ4XjBrXhl2X8AVeYs7wUysqx7GyJo8EaRkbdrx3iuBhdAaidFySzkVdSeVZiFOx0CkmZycmVB5XNXkJQwq_7CVxTlVAji06wkLS4XFYZWTdlX9s',
      code: 'zh',
      available: true,
    ),

    LanguageOption(
      name: 'Japanese',
      subtitle: 'こんにちは',
      flagUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBwYfUyX0byXwlYqptM4PnWwZdStwI4R-XylHm3-ogLozSEUXewMzi8jzp_welEzXElKWF3nln7-c8oNuzlrcPCEgCLRrbP2yOfeBaSJYC0XquGso6Tsl0WlKomBeHcVmWiPt900bSeDaJHlQGilRkjCq3m7z8Krf0onW_QmfRlY06_YOc2YjihXe2x9HifpQWvNrd89-wYg_sQuoR0jhlWhgbefOYhXRj6ISsRJeJLeZ5WuKgVEYDinM2T8YicGk2sGKjApwSIuxo',
      code: 'ja',
      available: false,
    ),
    LanguageOption(
      name: 'Korean',
      subtitle: '안녕하세요',
      flagUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA1PC1nsXp9OvwgQuD4vA_mq6-lFsgJ94vIh0H8gVf-Gd3fJZXabnGezXd4e25_leUzLFjvLF2L_7JyYPkSepdf8k0uRYvZ5aSJRJMvr8kPx9URogpxYreirui6KdwyjKubfjwUGEViLB2l87x5JTHe9eZEiSjjeDx1fHr4wIp0p1i-boGVYkmWUtaTlJAqZZBoCxBZ4MwsDA6JNPmACXzsMpucGXsFD5txq9TkpUgWBTp3yWNH3RrRZbUeWycbkLrJVDxTC7I0WBU',
      code: 'ko',
      available: false,
    ),
    LanguageOption(
      name: 'Spanish',
      subtitle: 'Hola',
      flagUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAECg0tPmVV8fo0cpg60DTlKjut-5A6zUT57ZcLUtLACWFnvv4-GmINVYnddPWgBu5rNd9s2reqd3GTB71TikA7HEZwap9QUUWphOG94qwPWCYMUwc1xAh-aAWiE4dd0mTd9JUmvgKtqzAVLVwL7ITVI6hHQMwTD6NLv-VFnCjpxDHvGDL99V4LyKWXzr343m52lWVJUgApMAqyCYFU6hwMUOsco1M5d6SvP_i21IGMJqjFLHh5YeDY8t5NL7P3WrkYgR5-nlpmKEw',
      code: 'es',
      available: false,
    ),
  ];

  static const List<LanguageOption> nativeLanguages = [
    LanguageOption(
      code: 'en',
      name: 'English',
      subtitle: 'English',
      flagUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB3o9h13vMUw0UlVF3KGfZ_GibGHgDzzI4cUYybLts9J2ZrM8v006e9A91nnplDP4TBmu3C3cqbGG_SVG9wtG1UOXqklHUUFdWGvvQ0dcqlXLHrdLIytG6I2HE4zRadCKpOYm_vnjXgc4DIa5eRfJvlC9HbTicodMY7fVXJ93LD2S2H-biRrfFoG5-Au1SxC-BoYcLpdhL81FI45PfguWBJA8onzM3ePPF-JKLk9BMiJuOzaOAdzZmf0sxNzHvyGJ3dQYggEf4GRpk',
    ),
    LanguageOption(
      code: 'es',
      name: 'Spanish',
      subtitle: 'Español',
      flagUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAECg0tPmVV8fo0cpg60DTlKjut-5A6zUT57ZcLUtLACWFnvv4-GmINVYnddPWgBu5rNd9s2reqd3GTB71TikA7HEZwap9QUUWphOG94qwPWCYMUwc1xAh-aAWiE4dd0mTd9JUmvgKtqzAVLVwL7ITVI6hHQMwTD6NLv-VFnCjpxDHvGDL99V4LyKWXzr343m52lWVJUgApMAqyCYFU6hwMUOsco1M5d6SvP_i21IGMJqjFLHh5YeDY8t5NL7P3WrkYgR5-nlpmKEw',
    ),
    LanguageOption(
      code: 'fr',
      name: 'French',
      subtitle: 'Français',
      flagUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDwOm5KmmFIac7iciPwsWWR4e__D4dPGDx83ROBvFEF8W5Z2r5c6tnbaC2pPSJrcvR0V6yQGEIUN0EEXi6Ct4esoEoxFhCAUj6zhS7kY8dmGBzcd3G4s0HXwdchth1hqSRqMFhnxKherszvl-D5gqBwVfFRPXolakN3LDtN7GcYGRlumy7jSPYwTwYwsQ9bW50rNQ7WiS1RascDQtWToTrqTDD4ahTuUnyvGxKUgX0L12d1MDiSszEjon02ZdBF2usbFqcJlllTjEE',
    ),
    LanguageOption(
      code: 'de',
      name: 'German',
      subtitle: 'Deutsch',
      flagUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBHmhqJoZsTIjCSZMQp28s8jBVIZgQ7RxXIK7o3nZUHm7Cgx9Bj85fd-JVnzzKQBbOtQWwp_E5NZ30BJX7II3yp-sR0Kw7tvVjk_bUv06ZOaiD7S6FUOvVwn8sGehuxQwBGHn_3Gf7PYw7WqqFWKNRdng89OOEDvDT8gHEiIGd4o3rIxG7EuIIgh4CIdI_UXu2WsLmWPebnWiYuAf_ZCoVeopRmWIR8bViUx8riI3s45in5s_VA6ZBJxmnYzjLBrrbKuO3vBc2i8Rs',
    ),
    LanguageOption(
      code: 'ja',
      name: 'Japanese',
      subtitle: '日本語',
      flagUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBwYfUyX0byXwlYqptM4PnWwZdStwI4R-XylHm3-ogLozSEUXewMzi8jzp_welEzXElKWF3nln7-c8oNuzlrcPCEgCLRrbP2yOfeBaSJYC0XquGso6Tsl0WlKomBeHcVmWiPt900bSeDaJHlQGilRkjCq3m7z8Krf0onW_QmfRlY06_YOc2YjihXe2x9HifpQWvNrd89-wYg_sQuoR0jhlWhgbefOYhXRj6ISsRJeJLeZ5WuKgVEYDinM2T8YicGk2sGKjApwSIuxo',
    ),
    LanguageOption(
      code: 'zh',
      name: 'Chinese',
      subtitle: '中文',
      flagUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBp76FMK1clf0RSjXXjSEP95JDYe7KyWPLzeHN8o9ki1b5iIhdWF_JV9SEvdQxnlKoq7Wg07mSuPWs8auuEdQih_4fvjALgMWGsUXRSQ6TzAm0nCZDwX54-VIh0-Hns4nlTcrihwbKo4jKQakgkY90miEKt6ATzZ4XjBrXhl2X8AVeYs7wUysqx7GyJo8EaRkbdrx3iuBhdAaidFySzkVdSeVZiFOx0CkmZycmVB5XNXkJQwq_7CVxTlVAji06wkLS4XFYZWTdlX9s',
    ),
    LanguageOption(
      code: 'ko',
      name: 'Korean',
      subtitle: '한국어',
      flagUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA1PC1nsXp9OvwgQuD4vA_mq6-lFsgJ94vIh0H8gVf-Gd3fJZXabnGezXd4e25_leUzLFjvLF2L_7JyYPkSepdf8k0uRYvZ5aSJRJMvr8kPx9URogpxYreirui6KdwyjKubfjwUGEViLB2l87x5JTHe9eZEiSjjeDx1fHr4wIp0p1i-boGVYkmWUtaTlJAqZZBoCxBZ4MwsDA6JNPmACXzsMpucGXsFD5txq9TkpUgWBTp3yWNH3RrRZbUeWycbkLrJVDxTC7I0WBU',
    ),
    LanguageOption(
      code: 'pt',
      name: 'Portuguese',
      subtitle: 'Português',
      flagUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD3S9zIxo4YYVcX4a1fQOdFliN5UYl_zqk6Bgm2-nzBZVqCr7J78SPJnvBPS5XunRN60_SiHhRgvq787vw1RJmmAugtyI2-jZSyP0YK3QAoAYG-kqs5aBcWmUmPkv_qT3WqE7I2PGH8vKujDE9PshVXVBmL6fpwrPgwLwNqTOa8Q4qa1WIHOTVn-XCLy8YySG1sn9IJsEGW3hDo0ClHkq7Giu-si8ALHZbdddOdNInStiOLmZ4YE6LnvGyfX0ol0xco3Ua9fHqJxt8',
    ),
  ];
}
