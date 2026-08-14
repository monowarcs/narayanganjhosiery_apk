/// Bangladesh divisions → districts — copied from js/config.js BD_LOCATIONS.
library;

const Map<String, List<String>> bdLocations = {
  'Dhaka': [
    'Dhaka',
    'Gazipur',
    'Narayanganj',
    'Tangail',
    'Kishoreganj',
    'Manikganj',
    'Munshiganj',
    'Faridpur',
    'Madaripur',
    'Shariatpur',
    'Rajbari',
    'Gopalganj',
    'Narsingdi',
  ],
  'Chattogram': [
    'Chattogram',
    "Cox's Bazar",
    'Cumilla',
    'Brahmanbaria',
    'Chandpur',
    'Feni',
    'Noakhali',
    'Lakshmipur',
    'Rangamati',
    'Khagrachhari',
    'Bandarban',
  ],
  'Rajshahi': [
    'Rajshahi',
    'Pabna',
    'Natore',
    'Sirajganj',
    'Bogra',
    'Naogaon',
    'Chapainawabganj',
    'Joypurhat',
  ],
  'Khulna': [
    'Khulna',
    'Bagerhat',
    'Satkhira',
    'Jessore',
    'Jhenaidah',
    'Magura',
    'Narail',
    'Kushtia',
    'Chuadanga',
    'Meherpur',
  ],
  'Barishal': [
    'Barishal',
    'Bhola',
    'Patuakhali',
    'Pirojpur',
    'Barguna',
    'Jhalokati',
  ],
  'Sylhet': ['Sylhet', 'Moulvibazar', 'Habiganj', 'Sunamganj'],
  'Rangpur': [
    'Rangpur',
    'Dinajpur',
    'Nilphamari',
    'Gaibandha',
    'Kurigram',
    'Lalmonirhat',
    'Panchagarh',
    'Thakurgaon',
  ],
  'Mymensingh': ['Mymensingh', 'Jamalpur', 'Netrokona', 'Sherpur'],
};

/// Hero slides — copied from js/config.js HERO_SLIDES.
class HeroSlide {
  final String image;
  final String eyebrow;
  final String title;
  final String desc;
  final String primaryText;
  final String primaryLink;
  final String secondaryText;
  final String secondaryLink;
  const HeroSlide({
    required this.image,
    required this.eyebrow,
    required this.title,
    required this.desc,
    required this.primaryText,
    required this.primaryLink,
    required this.secondaryText,
    required this.secondaryLink,
  });
}

const List<HeroSlide> heroSlides = [
  HeroSlide(
    image: 'assets/images/hero/slide-1.png',
    eyebrow: 'নতুন কালেকশন ২০২৬',
    title: 'নতুন পোশাকের সংগ্রহ',
    desc: 'নারী, পুরুষ ও শিশুদের জন্য মানসম্মত পোশাক ও হোসিয়ারি — এক ছাদের নিচে।',
    primaryText: 'এখনই কেনাকাটা করুন',
    primaryLink: 'shop',
    secondaryText: 'পণ্য দেখুন',
    secondaryLink: 'shop',
  ),
  HeroSlide(
    image: 'assets/images/hero/slide-2.png',
    eyebrow: 'খুচরা ও পাইকারি',
    title: 'ভালো মান, ন্যায্য দাম',
    desc: 'পাইকারি বিক্রয় উপলব্ধ — প্রতি ডজন সাশ্রয়ী মূল্যে।',
    primaryText: 'পাইকারি দেখুন',
    primaryLink: 'shop',
    secondaryText: 'যোগাযোগ করুন',
    secondaryLink: 'contact',
  ),
  HeroSlide(
    image: 'assets/images/hero/slide-3.png',
    eyebrow: 'পাবনার বিশ্বস্ত দোকান',
    title: 'পাবনার বিশ্বস্ত পোশাকের দোকান',
    desc: 'Narayanganj Hosiery, Pabna — আন্তরিক সেবা, নির্ভরযোগ্য মান।',
    primaryText: 'আমাদের সম্পর্কে',
    primaryLink: 'about',
    secondaryText: 'লোকেশন দেখুন',
    secondaryLink: 'contact',
  ),
];
