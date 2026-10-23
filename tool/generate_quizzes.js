const fs = require('fs');
const path = require('path');

const quizData = [
  // -------------------------------------------------------------
  // LEVEL 1: Pemula (Dasar Algoritma & Perintah Maju())
  // -------------------------------------------------------------
  {
    level: 1,
    diffId: 'Pemula',
    diffEn: 'Beginner',
    questions: [
      {
        qId: 'Apa yang dimaksud dengan algoritma dalam pemrograman komputer?',
        qEn: 'What is an algorithm in computer programming?',
        optsId: [
          'Urutan langkah logis dan sistematis untuk menyelesaikan suatu masalah',
          'Bahasa rahasia yang hanya dipahami oleh mesin komputer',
          'Tombol fisik untuk menyalakan perangkat elektronik',
          'Daftar angka acak tanpa susunan yang pasti'
        ],
        optsEn: [
          'A logical and systematic sequence of steps to solve a problem',
          'A secret language understood only by computer hardware',
          'A physical button to turn on electronic devices',
          'A list of random numbers without defined order'
        ],
        correct: 0,
        expId: 'Algoritma adalah susunan langkah-langkah logis dan terstruktur yang dibuat untuk mencapai tujuan tertentu.',
        expEn: 'An algorithm is a logical and structured sequence of steps designed to achieve a specific goal.'
      },
      {
        qId: 'Pada game AlgoQuest, apa fungsi dari perintah Maju()?',
        qEn: 'In AlgoQuest, what is the function of the Move() command?',
        optsId: [
          'Memutar arah hadap karakter ke belakang',
          'Menggerakkan karakter 1 petak ke arah depan yang sedang dihadapi',
          'Menghancurkan dinding yang menghalangi jalan',
          'Mengurangi darah monster secara otomatis'
        ],
        optsEn: [
          'Turn the character facing backward',
          'Move the character 1 tile forward in the current facing direction',
          'Destroy walls blocking the pathway',
          'Automatically reduce monster health'
        ],
        correct: 1,
        expId: 'Perintah Maju() melangkahkan karakter sejauh satu petak lurus ke arah pandangannya saat ini.',
        expEn: 'The Move() command moves the character forward one tile in its current facing direction.'
      },
      {
        qId: 'Jika karakter sedang menghadap ke arah Utara dan menjalankan Maju(), ke mana karakter berpindah?',
        qEn: 'If the character faces North and executes Move(), where does it move?',
        optsId: [
          '1 petak ke arah Selatan',
          '1 petak ke arah Timur',
          '1 petak ke arah Utara',
          '1 petak ke arah Barat'
        ],
        optsEn: [
          '1 tile to the South',
          '1 tile to the East',
          '1 tile to the North',
          '1 tile to the West'
        ],
        correct: 2,
        expId: 'Karakter selalu melangkah maju mengikuti arah mata angin yang sedang dihadapinya, yaitu Utara.',
        expEn: 'The character always steps forward following its facing direction, which is North.'
      },
      {
        qId: 'Berapa kali perintah Maju() harus dipanggil jika karakter ingin melangkah sejauh 3 petak lurus?',
        qEn: 'How many times must Move() be called if the character wants to move 3 tiles forward?',
        optsId: ['1 kali', '2 kali', '3 kali', '4 kali'],
        optsEn: ['1 time', '2 times', '3 times', '4 times'],
        correct: 2,
        expId: 'Setiap perintah Maju() memindahkan karakter 1 petak, sehingga untuk 3 petak diperlukan 3 kali pemanggilan.',
        expEn: 'Each Move() command moves the character 1 tile, so 3 calls are required for 3 tiles.'
      },
      {
        qId: 'Manakah pernyataan yang BENAR mengenai instruksi dalam sebuah algoritma?',
        qEn: 'Which statement is TRUE regarding instructions in an algorithm?',
        optsId: [
          'Instruksi boleh memiliki makna ganda dan membingungkan',
          'Setiap instruksi harus jelas, pasti, dan dieksekusi secara berurutan',
          'Komputer dapat menebak sendiri instruksi yang terlewat',
          'Urutan langkah tidak berpengaruh pada hasil akhir program'
        ],
        optsEn: [
          'Instructions may have ambiguous and confusing meanings',
          'Every instruction must be clear, unambiguous, and executed sequentially',
          'The computer can automatically guess missing instructions',
          'The sequence of steps has no effect on the program outcome'
        ],
        correct: 1,
        expId: 'Instruksi dalam algoritma harus jelas, terdefinisi dengan pasti, dan terurut agar komputer memprosesnya dengan benar.',
        expEn: 'Algorithm instructions must be unambiguous, clearly defined, and ordered for computers to execute them correctly.'
      }
    ]
  },

  // -------------------------------------------------------------
  // LEVEL 2: Pemula (Perintah Belok Kanan(), Belok Kiri(), dan Arah Hadap)
  // -------------------------------------------------------------
  {
    level: 2,
    diffId: 'Pemula',
    diffEn: 'Beginner',
    questions: [
      {
        qId: 'Apa perbedaan mendasar antara perintah Maju() dan Belok Kanan()?',
        qEn: 'What is the fundamental difference between Move() and TurnRight()?',
        optsId: [
          'Maju() mengubah arah hadap, Belok Kanan() memindahkan petak',
          'Maju() memindahkan posisi petak, Belok Kanan() hanya mengubah arah hadap',
          'Maju() menyerang musuh, Belok Kanan() memulihkan energi',
          'Tidak ada perbedaan antara kedua perintah tersebut'
        ],
        optsEn: [
          'Move() changes orientation, TurnRight() changes tile position',
          'Move() changes tile position, TurnRight() only changes facing direction',
          'Move() attacks enemies, TurnRight() restores energy',
          'There is no difference between the two commands'
        ],
        correct: 1,
        expId: 'Belok Kanan() hanya memutar orientasi karakter 90 derajat ke kanan tanpa mengubah koordinat petaknya.',
        expEn: 'TurnRight() only rotates the character orientation 90 degrees right without altering its tile position.'
      },
      {
        qId: 'Karakter sedang menghadap ke Utara. Setelah mengeksekusi Belok Kanan(), ke mana arah pandang karakter?',
        qEn: 'The character faces North. After executing TurnRight(), which direction does it face?',
        optsId: ['Timur', 'Barat', 'Selatan', 'Tetap Utara'],
        optsEn: ['East', 'West', 'South', 'Still North'],
        correct: 0,
        expId: 'Putaran 90 derajat searah jarum jam dari arah Utara adalah arah Timur.',
        expEn: 'A 90-degree clockwise rotation from North faces East.'
      },
      {
        qId: 'Karakter sedang menghadap ke Timur. Perintah apa yang dibutuhkan agar karakter menghadap ke Utara?',
        qEn: 'The character faces East. Which command is needed to face North?',
        optsId: ['Maju()', 'Belok Kanan()', 'Belok Kiri()', 'Serang()'],
        optsEn: ['Move()', 'TurnRight()', 'TurnLeft()', 'Attack()'],
        correct: 2,
        expId: 'Berbelok 90 derajat berlawanan jarum jam (kiri) dari Timur akan menghadap kembali ke Utara.',
        expEn: 'Turning 90 degrees counter-clockwise (left) from East will face North.'
      },
      {
        qId: 'Berapa kali Belok Kanan() harus dipanggil berturut-turut agar karakter berbalik 180 derajat ke belakang?',
        qEn: 'How many consecutive TurnRight() calls are needed to turn 180 degrees backward?',
        optsId: ['1 kali', '2 kali', '3 kali', '4 kali'],
        optsEn: ['1 time', '2 times', '3 times', '4 times'],
        correct: 1,
        expId: 'Dua kali putaran 90 derajat menghasilkan putaran 180 derajat (menghadap ke arah belakang).',
        expEn: 'Two 90-degree turns result in a 180-degree rotation (facing backward).'
      },
      {
        qId: 'Karakter menghadap Selatan dan menjalankan: Belok Kiri() lalu Belok Kanan(). Ke mana arah hadap akhir?',
        qEn: 'Character faces South and runs: TurnLeft() then TurnRight(). Where does it face finally?',
        optsId: ['Barat', 'Utara', 'Timur', 'Selatan'],
        optsEn: ['West', 'North', 'East', 'South'],
        correct: 3,
        expId: 'Belok kiri lalu belok kanan saling meniadakan, sehingga arah hadap tetap sama seperti semula (Selatan).',
        expEn: 'Turn left followed by turn right cancel each other out, preserving the original direction (South).'
      }
    ]
  },

  // -------------------------------------------------------------
  // LEVEL 3: Pemula (Boss Goblin Algoritma & Perintah Serang())
  // -------------------------------------------------------------
  {
    level: 3,
    diffId: 'Pemula',
    diffEn: 'Beginner',
    questions: [
      {
        qId: 'Kapan perintah Serang() paling tepat dijalankan oleh karakter?',
        qEn: 'When is the Attack() command most appropriately executed?',
        optsId: [
          'Saat karakter baru berada di petak awal dungeon',
          'Saat karakter sudah berada tepat di petak depan monster dan menghadapnya',
          'Saat karakter masih berjarak 5 petak dari monster',
          'Saat karakter sedang berhadapan dengan dinding labirin'
        ],
        optsEn: [
          'When the character is still at the starting dungeon tile',
          'When the character is directly in front of the monster and facing it',
          'When the character is 5 tiles away from the monster',
          'When the character is facing an empty maze wall'
        ],
        correct: 1,
        expId: 'Serang() hanya efektif mengenai musuh jika karakter sudah berada tepat di depan monster dan menghadap ke arahnya.',
        expEn: 'Attack() only hits the target if the character is directly facing the monster on an adjacent tile.'
      },
      {
        qId: 'Goblin Algoritma memiliki 1 HP. Berapa kali Serang() harus dipanggil saat sudah berhadapan langsung?',
        qEn: 'Algorithm Goblin has 1 HP. How many times must Attack() be called when directly facing it?',
        optsId: ['1 kali', '2 kali', '3 kali', '4 kali'],
        optsEn: ['1 time', '2 times', '3 times', '4 times'],
        correct: 0,
        expId: 'Satu kali tebasan Serang() mengurangi 1 HP Goblin Algoritma hingga habis (0 HP).',
        expEn: 'A single Attack() strike reduces the Goblin 1 HP to 0.'
      },
      {
        qId: 'Apa arti dari prinsip eksekusi sekuensial dalam pemrograman?',
        qEn: 'What does the sequential execution principle mean in programming?',
        optsId: [
          'Instruksi dijalankan secara acak oleh prosesor',
          'Instruksi diproses berurutan satu per satu dari langkah pertama hingga akhir',
          'Instruksi dijalankan tanpa pernah berhenti',
          'Instruksi dilewati jika karakter kelelahan'
        ],
        optsEn: [
          'Instructions are executed randomly by the processor',
          'Instructions are processed one by one in order from first to last step',
          'Instructions are repeated endlessly without stopping',
          'Instructions are skipped whenever the character is tired'
        ],
        correct: 1,
        expId: 'Struktur sekuensial menjamin bahwa perintah dieksekusi secara teratur baris demi baris.',
        expEn: 'Sequential structure ensures that commands run line by line in strict sequence.'
      },
      {
        qId: 'Karakter tepat di depan Goblin dan menghadapnya. Jika urutan kodenya Serang() lalu Maju(), apa hasilnya?',
        qEn: 'Facing Goblin directly, if code order is Attack() then Move(), what happens?',
        optsId: [
          'Goblin kalah terlebih dahulu, lalu karakter melangkah maju ke petak Goblin',
          'Karakter otomatis kalah oleh Goblin',
          'Goblin kabur sebelum terkena tebasan',
          'Program mengalami kesalahan fatal'
        ],
        optsEn: [
          'Goblin is defeated first, then character moves onto Goblin tile',
          'Character is automatically defeated by Goblin',
          'Goblin escapes before taking damage',
          'The program encounters a fatal crash'
        ],
        correct: 0,
        expId: 'Perintah Serang() pertama menghabisi Goblin, lalu Maju() menempati petak yang baru saja kosong.',
        expEn: 'Attack() defeats the Goblin first, and Move() advances onto the vacated tile.'
      },
      {
        qId: 'Mengapa urutan instruksi sangat penting dalam menyelesaikan algoritma pertarungan?',
        qEn: 'Why is instruction sequence crucial in resolving combat algorithms?',
        optsId: [
          'Karena urutan yang salah dapat menyebabkan karakter menyerang udara kosong atau menabrak dinding',
          'Karena urutan hanya penting untuk menghitung skor waktu',
          'Karena komputer akan otomatis membetulkan urutan yang salah',
          'Karena urutan perintah tidak memiliki dampak apa pun'
        ],
        optsEn: [
          'Because incorrect order can cause character to strike empty air or bump into walls',
          'Because order is only important for recording time score',
          'Because computers automatically rectify faulty ordering',
          'Because the sequence has no actual consequence'
        ],
        correct: 0,
        expId: 'Urutan instruksi menentukan ketepatan posisi dan aksi karakter; langkah yang terbalik akan berakibat fatal.',
        expEn: 'Instruction ordering determines character positioning and actions; reversed steps cause failure.'
      }
    ]
  },

  // -------------------------------------------------------------
  // LEVEL 4: Mudah (Penggabungan Dua Perintah & Menghitung Langkah)
  // -------------------------------------------------------------
  {
    level: 4,
    diffId: 'Mudah',
    diffEn: 'Easy',
    questions: [
      {
        qId: 'Target monster berada 2 petak lurus di depan karakter. Urutan perintah paling tepat untuk mengalahkannya?',
        qEn: 'The monster is 2 tiles straight ahead. What is the correct command sequence to defeat it?',
        optsId: [
          'Maju(), Belok Kanan(), Serang()',
          'Maju(), Maju(), Serang()',
          'Belok Kiri(), Maju(), Serang()',
          'Serang(), Maju(), Maju()'
        ],
        optsEn: [
          'Move(), TurnRight(), Attack()',
          'Move(), Move(), Attack()',
          'TurnLeft(), Move(), Attack()',
          'Attack(), Move(), Move()'
        ],
        correct: 1,
        expId: 'Karakter harus melangkah maju 2 petak terlebih dahulu, lalu melancarkan serangan.',
        expEn: 'The character must advance 2 tiles forward first, then execute Attack().'
      },
      {
        qId: 'Diberikan barisan kode: Maju(), Maju(), Maju(). Berapa total petak perpindahan karakter?',
        qEn: 'Given the code: Move(), Move(), Move(). How many tiles did the character displace?',
        optsId: ['1 petak', '2 petak', '3 petak', '4 petak'],
        optsEn: ['1 tile', '2 tiles', '3 tiles', '4 tiles'],
        correct: 2,
        expId: 'Tiga instruksi Maju() berurutan menghasilkan total perpindahan sejauh 3 petak.',
        expEn: 'Three consecutive Move() commands displace the character across 3 tiles.'
      },
      {
        qId: 'Karakter ingin maju 1 petak lalu memutar arah ke kanan. Urutan yang benar adalah...',
        qEn: 'Character wants to move 1 tile forward then turn right. What is the correct order?',
        optsId: [
          'Belok Kanan(), Maju()',
          'Maju(), Belok Kanan()',
          'Maju(), Belok Kiri()',
          'Belok Kiri(), Maju()'
        ],
        optsEn: [
          'TurnRight(), Move()',
          'Move(), TurnRight()',
          'Move(), TurnLeft()',
          'TurnLeft(), Move()'
        ],
        correct: 1,
        expId: 'Maju() melangkahkan karakter 1 petak, disusul Belok Kanan() untuk mengubah orientasi.',
        expEn: 'Move() displaces the character 1 tile, followed by TurnRight() to reorient.'
      },
      {
        qId: 'Jika di depan ada dinding, bagaimana urutan pencegahan tabrakan yang benar sebelum melangkah?',
        qEn: 'If a wall blocks the path, what is the correct collision avoidance sequence before stepping forward?',
        optsId: [
          'Menyerang dinding berulang kali',
          'Berbelok (kanan atau kiri) ke arah lorong terbuka terlebih dahulu sebelum Maju()',
          'Terus memanggil Maju()',
          'Mengabaikan dinding'
        ],
        optsEn: [
          'Repeatedly attacking the stone wall',
          'Turning (right or left) towards the open corridor before executing Move()',
          'Continuously calling Move()',
          'Ignoring the wall obstacle'
        ],
        correct: 1,
        expId: 'Karakter harus memutar arah terlebih dahulu ke lorong yang terbuka sebelum melangkah maju.',
        expEn: 'The character must first rotate towards the open hallway before executing Move().'
      },
      {
        qId: 'Mengapa menulis kode langkah demi langkah secara terstruktur mempermudah penyelesaian labirin?',
        qEn: 'Why does writing structured step-by-step code simplify maze resolution?',
        optsId: [
          'Mempermudah pelacakan pergerakan dan mencegah kesalahan logika saat menavigasi lorong',
          'Menghilangkan kebutuhan akan komputer',
          'Membuat karakter kebal dari rintangan',
          'Mengubah dinding menjadi jalan terbuka secara instan'
        ],
        optsEn: [
          'Facilitates path tracing and prevents logic flaws during corridor navigation',
          'Eliminates the need for computers',
          'Grants immunity from obstacles',
          'Instantly turns walls into open paths'
        ],
        correct: 0,
        expId: 'Struktur kode yang sistematis memudahkan pemain memantau koordinat dan mendeteksi titik kesalahan.',
        expEn: 'Systematic code structure helps players track coordinates and locate flaws quickly.'
      }
    ]
  },

  // -------------------------------------------------------------
  // LEVEL 5: Mudah (Urutan Belok dan Maju Jalur Berliku Huruf L)
  // -------------------------------------------------------------
  {
    level: 5,
    diffId: 'Mudah',
    diffEn: 'Easy',
    questions: [
      {
        qId: 'Jalur labirin berbentuk huruf "L": Maju 2 petak, belok kiri, lalu maju 1 petak. Urutan kode yang tepat?',
        qEn: 'The maze forms an "L" path: Move 2 tiles, turn left, then move 1 tile. What is the correct code?',
        optsId: [
          'Maju(), Belok Kanan(), Maju(2)',
          'Maju(), Maju(), Belok Kiri(), Maju()',
          'Belok Kiri(), Maju(3)',
          'Maju(), Belok Kanan(), Belok Kanan()'
        ],
        optsEn: [
          'Move(), TurnRight(), Move(2)',
          'Move(), Move(), TurnLeft(), Move()',
          'TurnLeft(), Move(3)',
          'Move(), TurnRight(), TurnRight()'
        ],
        correct: 1,
        expId: 'Maju dua petak untuk sisi pertama, Belok Kiri pada tikungan, lalu Maju satu petak mencapai tujuan.',
        expEn: 'Advance two tiles for the first leg, TurnLeft at the corner, and Move one tile to reach the target.'
      },
      {
        qId: 'Karakter menghadap Timur. Setelah mengeksekusi Belok Kiri(), ke mana arah pandang karakter sekarang?',
        qEn: 'Character faces East. After executing TurnLeft(), which direction does it face now?',
        optsId: ['Utara', 'Selatan', 'Barat', 'Tetap Timur'],
        optsEn: ['North', 'South', 'West', 'Still East'],
        correct: 0,
        expId: 'Berbelok 90 derajat ke kiri dari arah Timur menghasilkan arah hadap Utara.',
        expEn: 'Turning 90 degrees counter-clockwise (left) from East faces North.'
      },
      {
        qId: 'Analisis urutan: Maju(), Belok Kanan(), Maju(), Belok Kiri(). Apa orientasi arah hadap akhir karakter?',
        qEn: 'Analyze the sequence: Move(), TurnRight(), Move(), TurnLeft(). What is the final facing direction?',
        optsId: [
          'Berbelok 90 derajat ke kanan dari arah awal',
          'Sama persis dengan arah hadap semula',
          'Berbalik 180 derajat ke belakang',
          'Menghadap ke bawah tanah'
        ],
        optsEn: [
          'Rotated 90 degrees right from original',
          'Identical to the original facing orientation',
          'Reversed 180 degrees backward',
          'Pointing downwards into the ground'
        ],
        correct: 1,
        expId: 'Belok Kanan diikuti Belok Kiri menetralkan rotasi, sehingga arah pandang akhir sama dengan arah awal.',
        expEn: 'TurnRight followed by TurnLeft neutralizes the rotation, maintaining the starting orientation.'
      },
      {
        qId: 'Apa yang terjadi jika karakter berada di depan tikungan, tetapi pemain lupa menulis perintah belok?',
        qEn: 'What occurs if the character reaches a corner but the player forgets to include a turn command?',
        optsId: [
          'Karakter otomatis memutar badan sendiri',
          'Karakter tetap melangkah lurus dan menabrak dinding di depannya',
          'Monster otomatis menyerah',
          'Karakter melompati dinding'
        ],
        optsEn: [
          'Character automatically reorients itself',
          'Character steps straight forward and bumps into the wall ahead',
          'Monster surrenders automatically',
          'Character leaps over the barricade'
        ],
        correct: 1,
        expId: 'Komputer hanya menjalankan instruksi yang tertulis; tanpa perintah belok, karakter akan menabrak dinding.',
        expEn: 'Computers strictly execute specified instructions; without a turn command, the character hits the wall.'
      },
      {
        qId: 'Merencanakan urutan rute sebelum menulis kode merupakan penerapan computational thinking yaitu...',
        qEn: 'Planning path sequences before writing code exemplifies which computational thinking pillar?',
        optsId: [
          'Dekomposisi dan perancangan algoritma',
          'Menebak secara acak',
          'Menghapus instruksi',
          'Menolak instruksi'
        ],
        optsEn: [
          'Decomposition and algorithm design',
          'Random guesswork',
          'Deleting instructions',
          'Rejecting instructions'
        ],
        correct: 0,
        expId: 'Membagi rute menjadi langkah-langkah kecil teratur adalah proses dekomposisi dan perancangan algoritma.',
        expEn: 'Decomposing a path into discrete ordered steps is algorithm design and problem decomposition.'
      }
    ]
  },

  // -------------------------------------------------------------
  // LEVEL 6: Mudah Menuju Menengah (Boss Slime Variabel & Parameter Langkah)
  // -------------------------------------------------------------
  {
    level: 6,
    diffId: 'Mudah Menuju Menengah',
    diffEn: 'Easy-Intermediate',
    questions: [
      {
        qId: 'Boss Slime Variabel memiliki 2 HP. Saat sudah berhadapan langsung, berapa kali Serang() harus dipanggil?',
        qEn: 'Boss Variable Slime has 2 HP. Once directly facing it, how many times must Attack() be executed?',
        optsId: ['1 kali', '2 kali', '3 kali', '4 kali'],
        optsEn: ['1 time', '2 times', '3 times', '4 times'],
        correct: 1,
        expId: 'Setiap serangan mengurangi 1 HP. Untuk menghabisi 2 HP Slime dibutuhkan tepat 2 kali Serang().',
        expEn: 'Each attack deals 1 damage. Defeating a 2-HP Slime requires exactly 2 Attack() calls.'
      },
      {
        qId: 'Pada blok perintah AlgoQuest, apa keunggulan instruksi Maju(3) dibanding tiga baris Maju() terpisah?',
        qEn: 'In AlgoQuest blocks, what is the advantage of Move(3) over three separate Move() lines?',
        optsId: [
          'Lebih ringkas, menghemat kuota blok par, dan kode mudah dipahami',
          'Membuat karakter berlari lebih cepat di dunia nyata',
          'Memberikan kekebalan dari seluruh serangan musuh',
          'Menghapus monster secara otomatis'
        ],
        optsEn: [
          'More concise, conserves block budget, and improves code readability',
          'Makes the character physically run faster in real life',
          'Grants total invulnerability to enemy strikes',
          'Eliminates monsters automatically'
        ],
        correct: 0,
        expId: 'Menggabungkan langkah menjadi parameter Maju(3) menghemat batas blok maksimal (par) pada level.',
        expEn: 'Combining repeated steps into parameter Move(3) conserves the par block budget.'
      },
      {
        qId: 'Target Slime (HP: 2) berjarak 3 petak lurus. Kode paling hemat blok dan tepat adalah...',
        qEn: 'Target Slime (HP: 2) is 3 tiles straight ahead. What is the most efficient code sequence?',
        optsId: [
          'Maju(3), Serang(), Serang()',
          'Maju(1), Serang(), Maju(2)',
          'Serang(2), Maju(3)',
          'Belok Kanan(), Maju(3)'
        ],
        optsEn: [
          'Move(3), Attack(), Attack()',
          'Move(1), Attack(), Move(2)',
          'Attack(2), Move(3)',
          'TurnRight(), Move(3)'
        ],
        correct: 0,
        expId: 'Maju(3) membawa karakter tepat ke depan Slime, disusul 2 kali Serang() untuk menghabisi 2 HP-nya.',
        expEn: 'Move(3) lands the character in front of the Slime, followed by 2 Attack() strikes to deplete its 2 HP.'
      },
      {
        qId: 'Dalam konsep pemrograman, nilai "HP Monster = 2" merupakan contoh dari...',
        qEn: 'In programming terminology, the value "Monster HP = 2" represents an example of a...',
        optsId: [
          'Variabel numerik yang menyimpan status dan dapat dimanipulasi',
          'Gambar hiasan latar belakang',
          'Dinding permanen yang tidak dapat diubah',
          'Nama perangkat keras komputer'
        ],
        optsEn: [
          'Numeric variable holding state that can be manipulated',
          'Decorative background asset',
          'Permanent immutable boundary wall',
          'Computer hardware model name'
        ],
        correct: 0,
        expId: 'HP adalah variabel numerik yang nilainya berkurang setiap kali terkena aksi Serang().',
        expEn: 'HP is a numeric variable whose value decrements with each Attack() action.'
      },
      {
        qId: 'Jika sebuah variabel langkah bernilai 6 dan karakter memanggil Maju(4), berapakah sisa nilai langkah?',
        qEn: 'If a step variable holds value 6 and the character executes Move(4), what is the remaining step value?',
        optsId: ['1', '2', '3', '10'],
        optsEn: ['1', '2', '3', '10'],
        correct: 1,
        expId: '6 dikurangi 4 menghasilkan 2 langkah tersisa.',
        expEn: '6 minus 4 leaves 2 remaining steps.'
      }
    ]
  },

  // -------------------------------------------------------------
  // LEVEL 7: Menengah (Pengenalan Percabangan & Struktur JIKA)
  // -------------------------------------------------------------
  {
    level: 7,
    diffId: 'Menengah',
    diffEn: 'Intermediate',
    questions: [
      {
        qId: 'Apa fungsi utama struktur percabangan (Conditionals / If) dalam algoritma pemrograman?',
        qEn: 'What is the primary function of branching structures (Conditionals / If) in programming algorithms?',
        optsId: [
          'Mengambil keputusan dan menentukan aksi berdasarkan kondisi tertentu',
          'Mengulang perintah yang sama secara terus-menerus',
          'Menghapus seluruh baris kode yang sudah ditulis',
          'Menghentikan perangkat elektronik secara tiba-tiba'
        ],
        optsEn: [
          'Making decisions and selecting actions based on specific conditions',
          'Repeating identical commands continuously',
          'Deleting all written code lines',
          'Abruptly stopping hardware devices'
        ],
        correct: 0,
        expId: 'Percabangan memungkinkan program membuat keputusan cerdas sesuai kondisi yang sedang dihadapi.',
        expEn: 'Branching enables programs to make dynamic decisions based on environmental conditions.'
      },
      {
        qId: 'Kode: JIKA (Ada Dinding) MAKA Belok Kanan(). Apa yang terjadi jika di depan karakter jalanan terbuka?',
        qEn: 'Code: IF (Wall Ahead) THEN TurnRight(). What happens if the path ahead is open?',
        optsId: [
          'Karakter tetap Belok Kanan()',
          'Karakter tidak berbelok dan melewati blok JIKA untuk melanjutkan langkah berikutnya',
          'Karakter berjalan mundur',
          'Game otomatis terhenti'
        ],
        optsEn: [
          'Character still turns right',
          'Character skips the turn command and continues to the next instruction',
          'Character steps backward',
          'Game halts automatically'
        ],
        correct: 1,
        expId: 'Jika kondisi bernilai SALAH (tidak ada dinding), instruksi di dalam blok JIKA diabaikan.',
        expEn: 'When the condition evaluates to FALSE (no wall), the instruction inside the IF block is bypassed.'
      },
      {
        qId: 'Kapan instruksi di dalam blok JIKA (Kondisi) akan dieksekusi oleh program?',
        qEn: 'When will instructions inside an IF (Condition) block be executed by the program?',
        optsId: [
          'Hanya ketika kondisi tersebut bernilai Benar (True)',
          'Hanya ketika kondisi bernilai Salah (False)',
          'Selalu dieksekusi tanpa memeriksa kondisi',
          'Tidak pernah dieksekusi sama sekali'
        ],
        optsEn: [
          'Only when the condition evaluates to True',
          'Only when the condition evaluates to False',
          'Always executed without condition evaluation',
          'Never executed under any circumstance'
        ],
        correct: 0,
        expId: 'Blok percabangan IF hanya akan dieksekusi ketika kondisi yang disyaratkan bernilai Benar (True).',
        expEn: 'An IF branch executes exclusively when its predicate condition evaluates to True.'
      },
      {
        qId: 'Manakah kondisi percabangan yang paling tepat untuk mendeteksi apakah musuh siap ditebas?',
        qEn: 'Which branching condition is most appropriate to detect if an enemy is in melee range?',
        optsId: [
          'JIKA (Monster Berada di Depan)',
          'JIKA (Warna Lantai == Cokelat)',
          'JIKA (Baterai Penuh)',
          'JIKA (Karakter Menghadap Utara)'
        ],
        optsEn: [
          'IF (Monster In Front)',
          'IF (Floor Color == Brown)',
          'IF (Battery Full)',
          'IF (Facing North)'
        ],
        correct: 0,
        expId: 'Kondisi "Monster Berada di Depan" secara akurat menguji keberadaan musuh pada petak target serangan.',
        expEn: 'The condition "Monster In Front" accurately verifies enemy presence on the target attack tile.'
      },
      {
        qId: 'Apa tipe data hasil evaluasi dari suatu kondisi percabangan?',
        qEn: 'What is the data type of an evaluated conditional expression?',
        optsId: [
          'Boolean (Benar / True atau Salah / False)',
          'String teks bebas',
          'Bilangan pecahan desimal',
          'Daftar gambar karakter'
        ],
        optsEn: [
          'Boolean (True or False)',
          'Arbitrary text string',
          'Floating-point decimal number',
          'Character sprite list'
        ],
        correct: 0,
        expId: 'Setiap kondisi percabangan selalu menghasilkan nilai boolean: Benar (True) atau Salah (False).',
        expEn: 'Every conditional predicate evaluates strictly to a boolean value: True or False.'
      }
    ]
  },

  // -------------------------------------------------------------
  // LEVEL 8: Menengah (Percabangan JIKA - LAINNYA / If-Else)
  // -------------------------------------------------------------
  {
    level: 8,
    diffId: 'Menengah',
    diffEn: 'Intermediate',
    questions: [
      {
        qId: 'Pada struktur JIKA - LAINNYA (If-Else), kapan bagian LAINNYA (Else) akan dieksekusi?',
        qEn: 'In an IF - ELSE structure, when will the ELSE block be executed?',
        optsId: [
          'Ketika kondisi pada bagian JIKA bernilai Salah (False)',
          'Ketika kondisi pada bagian JIKA bernilai Benar (True)',
          'Selalu dieksekusi bersamaan dengan blok JIKA',
          'Hanya saat game pertama kali dibuka'
        ],
        optsEn: [
          'When the condition in the IF block evaluates to False',
          'When the condition in the IF block evaluates to True',
          'Always executed concurrently with the IF block',
          'Only when the game is launched for the first time'
        ],
        correct: 0,
        expId: 'Blok LAINNYA (Else) berfungsi sebagai jalur alternatif jika kondisi utama JIKA tidak terpenuhi (False).',
        expEn: 'The ELSE block serves as the fallback route whenever the primary IF condition is not met (False).'
      },
      {
        qId: 'Kode: JIKA (Jalan Kosong) MAKA Maju() LAINNYA Belok Kanan(). Jika di depan ada dinding, apa aksinya?',
        qEn: 'Code: IF (Clear Path) THEN Move() ELSE TurnRight(). If a wall blocks the path, what action occurs?',
        optsId: [
          'Maju()',
          'Belok Kanan()',
          'Serang()',
          'Diam tanpa aksi'
        ],
        optsEn: [
          'Move()',
          'TurnRight()',
          'Attack()',
          'Remain idle'
        ],
        correct: 1,
        expId: 'Karena jalan tidak kosong (kondisi False), instruksi yang dieksekusi adalah blok LAINNYA yaitu Belok Kanan().',
        expEn: 'Since the path is blocked (False), the ELSE block command TurnRight() is executed.'
      },
      {
        qId: 'Apa keunggulan menggunakan JIKA - LAINNYA dibanding rangkaian perintah sekuensial statis?',
        qEn: 'What is the key advantage of IF - ELSE over static sequential commands?',
        optsId: [
          'Program mampu beradaptasi dan memilih tindakan tepat pada situasi labirin yang berbeda-beda',
          'Menghapus kebutuhan menyusun algoritma',
          'Membuat karakter bergerak tanpa memerlukan kode',
          'Mempercepat animasi game hingga tidak terlihat'
        ],
        optsEn: [
          'The program adapts and chooses appropriate actions across varying maze layouts',
          'Removes the requirement of designing algorithms',
          'Allows character movement without code',
          'Speeds up animations until invisible'
        ],
        correct: 0,
        expId: 'Percabangan If-Else memberikan fleksibilitas logika untuk menangani kondisi tak terduga dalam labirin.',
        expEn: 'If-Else branching provides algorithmic flexibility to handle diverse maze contingencies.'
      },
      {
        qId: 'Kode: JIKA (HP Monster > 0) MAKA Serang() LAINNYA Lanjut(). Jika HP Monster = 0, apa aksi yang berjalan?',
        qEn: 'Code: IF (Monster HP > 0) THEN Attack() ELSE Continue(). If Monster HP is 0, which action executes?',
        optsId: [
          'Serang()',
          'Lanjut()',
          'Mundur()',
          'Kedua aksi berjalan bersamaan'
        ],
        optsEn: [
          'Attack()',
          'Continue()',
          'StepBack()',
          'Both actions run simultaneously'
        ],
        correct: 1,
        expId: 'Kondisi HP > 0 bernilai Salah karena HP = 0, sehingga aksi beralih ke cabang LAINNYA yaitu Lanjut().',
        expEn: 'Condition HP > 0 is False since HP is 0, directing execution to the ELSE branch (Continue).'
      },
      {
        qId: 'Berapa banyak cabang yang akan dieksekusi dalam satu struktur JIKA - LAINNYA sederhana?',
        qEn: 'How many branches will be executed in a single simple IF - ELSE block?',
        optsId: [
          'Tepat satu cabang (antara JIKA atau LAINNYA)',
          'Kedua cabang selalu dijalankan bersamaan',
          'Tidak ada cabang yang dijalankan',
          'Tiga cabang sekaligus'
        ],
        optsEn: [
          'Exactly one branch (either IF or ELSE)',
          'Both branches always execute together',
          'Neither branch executes',
          'Three branches simultaneously'
        ],
        correct: 0,
        expId: 'Struktur If-Else bersifat eksklusif: hanya satu cabang yang terpilih sesuai hasil evaluasi kondisi.',
        expEn: 'If-Else is mutually exclusive: exactly one branch is taken based on the evaluation result.'
      }
    ]
  },

  // -------------------------------------------------------------
  // LEVEL 9: Menengah (Boss Naga Percabangan & Pengambilan Keputusan Jalur)
  // -------------------------------------------------------------
  {
    level: 9,
    diffId: 'Menengah',
    diffEn: 'Intermediate',
    questions: [
      {
        qId: 'Boss Naga Percabangan memiliki 3 HP. Apa arti ekspresi perbandingan JIKA (Target == Naga)?',
        qEn: 'Boss Branch Dragon has 3 HP. What does the comparison IF (Target == Dragon) evaluate?',
        optsId: [
          'Memeriksa apakah musuh yang dihadapi berjenis Naga',
          'Mengubah musuh lain menjadi Naga',
          'Menghapus naga dari arena pertempuran',
          'Menyerah kepada naga'
        ],
        optsEn: [
          'Checks whether the targeted entity is of type Dragon',
          'Transforms another enemy into a Dragon',
          'Deletes the dragon from the arena',
          'Surrenders to the dragon'
        ],
        correct: 0,
        expId: 'Operator == digunakan untuk menguji kesamaan identitas antara objek target dengan tipe Naga.',
        expEn: 'The == equality operator compares whether the target matches the Dragon type.'
      },
      {
        qId: 'Naga memiliki 3 HP dan karakter sudah tepat di depannya. Urutan serangan untuk menang adalah...',
        qEn: 'Dragon has 3 HP and character directly faces it. What is the attack sequence to win?',
        optsId: [
          'Serang(), Serang(), Serang()',
          'Maju(), Serang(), Belok Kanan()',
          'Serang(), Belok Kiri(), Maju()',
          'Maju(3)'
        ],
        optsEn: [
          'Attack(), Attack(), Attack()',
          'Move(), Attack(), TurnRight()',
          'Attack(), TurnLeft(), Move()',
          'Move(3)'
        ],
        correct: 0,
        expId: 'Tiga kali pemanggilan Serang() secara sekuensial mengurangi 3 HP Naga hingga mencapai 0 HP.',
        expEn: 'Three sequential Attack() invocations deplete all 3 HP of the Dragon to 0.'
      },
      {
        qId: 'Kode: JIKA (Jalur Kiri == Aman) { Belok Kiri(); Maju(); } LAINNYA { Belok Kanan(); Maju(); }. Apa tujuannya?',
        qEn: 'Code: IF (Left Path == Safe) { TurnLeft(); Move(); } ELSE { TurnRight(); Move(); }. What is the goal?',
        optsId: [
          'Memilih rute aman secara dinamis di persimpangan sarang Naga',
          'Menyerang naga secara membabi buta',
          'Menabrak dinding di persimpangan',
          'Menghentikan jalannya game'
        ],
        optsEn: [
          'Dynamically choosing a safe pathway at the Dragon lair intersection',
          'Blindly attacking the dragon',
          'Colliding with intersection walls',
          'Aborting game execution'
        ],
        correct: 0,
        expId: 'Logika ini memeriksa keselamatan jalur kiri; jika berbahaya, otomatis beralih ke jalur kanan.',
        expEn: 'This logic tests left pathway safety; if compromised, it smoothly routes through the right path.'
      },
      {
        qId: 'Apa yang terjadi pada struktur percabangan bertingkat (If - Else If)?',
        qEn: 'What happens in a cascaded branching structure (If - Else If)?',
        optsId: [
          'Kondisi kedua hanya akan diuji jika kondisi pertama bernilai Salah (False)',
          'Seluruh kondisi dieksekusi serentak',
          'Kondisi kedua mengabaikan kondisi pertama',
          'Program otomatis mengalami kerusakan'
        ],
        optsEn: [
          'The second condition is tested only if the first condition evaluates to False',
          'All conditions execute simultaneously',
          'The second condition overrides the first unconditionally',
          'The program encounters an unhandled exception'
        ],
        correct: 0,
        expId: 'Pada else-if bertingkat, pemeriksaan kondisi berikutnya hanya dilakukan jika kondisi sebelumnya False.',
        expEn: 'In else-if cascades, subsequent conditions are checked only when previous conditions evaluate to False.'
      },
      {
        qId: 'Mengapa evaluasi kondisi yang cermat penting dalam pertarungan melawan Boss Naga?',
        qEn: 'Why is rigorous condition evaluation vital when combating the Dragon Boss?',
        optsId: [
          'Menghindari serangan ke petak kosong dan mencegah pemborosan langkah berharga',
          'Agar naga mendapatkan darah tambahan',
          'Supaya kode tidak dapat dibaca orang lain',
          'Untuk mematikan suara musik permainan'
        ],
        optsEn: [
          'Prevents swings into empty air and avoids wasting valuable par steps',
          'Heals the dragon bonus health',
          'Obfuscates code from readers',
          'Mutes background game audio'
        ],
        correct: 0,
        expId: 'Memeriksa kondisi dengan teliti memastikan karakter hanya menyerang saat musuh benar-benar berada di depannya.',
        expEn: 'Strict verification ensures characters attack only when enemies are genuinely within range.'
      }
    ]
  },

  // -------------------------------------------------------------
  // LEVEL 10: Sulit (Pengenalan Struktur Perulangan / Loops)
  // -------------------------------------------------------------
  {
    level: 10,
    diffId: 'Sulit',
    diffEn: 'Hard',
    questions: [
      {
        qId: 'Apa tujuan utama menggunakan struktur perulangan (Loops / Ulangi) dalam algoritma pemrograman?',
        qEn: 'What is the primary purpose of loop structures (Loops / Repeat) in programming algorithms?',
        optsId: [
          'Menjalankan blok instruksi yang sama berulang kali secara efisien tanpa menulis ulang kodenya',
          'Menghentikan program secara mendadak',
          'Menghapus variabel yang tersimpan di memori',
          'Membuat karakter berjalan mundur'
        ],
        optsEn: [
          'Executing identical code blocks iteratively without redundant code writing',
          'Abruptly terminating the program',
          'Clearing stored variables from memory',
          'Forcing the character to walk backward'
        ],
        correct: 0,
        expId: 'Perulangan (loop) membuat kode menjadi ringkas, modular, dan efisien untuk tugas yang berulang.',
        expEn: 'Loops provide concise, modular, and efficient execution for repetitive tasks.'
      },
      {
        qId: 'Blok kode: ULANGI (4) { Maju(); }. Hasil eksekusinya sama persis dengan...',
        qEn: 'Code block: REPEAT (4) { Move(); }. Its execution outcome is identical to...',
        optsId: [
          'Maju(), Maju(), Maju(), Maju()',
          'Maju(1), Belok Kanan(4)',
          'Maju(2), Serang(2)',
          'Belok Kiri(), Maju()'
        ],
        optsEn: [
          'Move(), Move(), Move(), Move()',
          'Move(1), TurnRight(4)',
          'Move(2), Attack(2)',
          'TurnLeft(), Move()'
        ],
        correct: 0,
        expId: 'Perulangan 4 kali dengan perintah Maju() identik dengan memanggil Maju() 4 kali berturut-turut.',
        expEn: 'Iterating 4 times with Move() is equivalent to invoking Move() 4 consecutive times.'
      },
      {
        qId: 'Analisis kode: ULANGI (3) { Maju(); Serang(); }. Berapa total pemanggilan perintah Serang()?',
        qEn: 'Code analysis: REPEAT (3) { Move(); Attack(); }. How many total times is Attack() called?',
        optsId: ['1 kali', '2 kali', '3 kali', '6 kali'],
        optsEn: ['1 time', '2 times', '3 times', '6 times'],
        correct: 2,
        expId: 'Setiap instruksi di dalam badan perulangan akan dieksekusi sebanyak jumlah iterasi, yaitu 3 kali.',
        expEn: 'Every instruction within the loop body runs across each iteration, totaling 3 times.'
      },
      {
        qId: 'Karakter berada di lorong lurus sepanjang 6 petak. Manakah penulisan algoritma yang paling ringkas?',
        qEn: 'Character is in a 6-tile straight corridor. Which algorithm representation is cleanest?',
        optsId: [
          'Menulis Maju() sebanyak 6 baris terpisah',
          'ULANGI (6) { Maju(); }',
          'Belok Kanan(), Belok Kiri() 6 kali',
          'Maju(), Serang(), Maju()'
        ],
        optsEn: [
          'Writing Move() on 6 separate sequential lines',
          'REPEAT (6) { Move(); }',
          'TurnRight(), TurnLeft() 6 times',
          'Move(), Attack(), Move()'
        ],
        correct: 1,
        expId: 'Menggunakan perulangan ULANGI (6) memadatkan 6 baris perintah menjadi satu struktur yang bersih dan elegan.',
        expEn: 'Using REPEAT (6) condenses 6 redundant lines into a clean and elegant structure.'
      },
      {
        qId: 'Apa yang terjadi jika suatu perulangan disetel dengan parameter ULANGI (0) { Maju(); }?',
        qEn: 'What happens when a loop is configured with parameter REPEAT (0) { Move(); }?',
        optsId: [
          'Maju() dijalankan 1 kali',
          'Badan perulangan tidak dijalankan sama sekali (0 kali)',
          'Program menghasilkan error pembagian nol',
          'Karakter melangkah mundur'
        ],
        optsEn: [
          'Move() executes 1 time',
          'The loop body does not execute at all (0 times)',
          'Program raises a division by zero exception',
          'Character steps in reverse'
        ],
        correct: 1,
        expId: 'Jumlah iterasi 0 berarti instruksi di dalam kurung kurawal tidak pernah dipanggil.',
        expEn: 'An iteration count of 0 ensures that instructions within the block are never invoked.'
      }
    ]
  },

  // -------------------------------------------------------------
  // LEVEL 11: Sulit (Perulangan Pola Navigasi Tangga & Zigzag)
  // -------------------------------------------------------------
  {
    level: 11,
    diffId: 'Sulit',
    diffEn: 'Hard',
    questions: [
      {
        qId: 'Labirin tangga: Maju 1, Belok Kanan, Maju 1, Belok Kiri berulang 3 kali. Rangkaian perulangan yang benar?',
        qEn: 'Staircase maze: Move 1, Turn Right, Move 1, Turn Left repeats 3 times. What is the correct loop?',
        optsId: [
          'ULANGI (3) { Maju(); Belok Kanan(); Maju(); Belok Kiri(); }',
          'ULANGI (3) { Maju(2); Belok Kanan(2); }',
          'Maju(6), Belok Kiri(3)',
          'ULANGI (1) { Maju(3); }'
        ],
        optsEn: [
          'REPEAT (3) { Move(); TurnRight(); Move(); TurnLeft(); }',
          'REPEAT (3) { Move(2); TurnRight(2); }',
          'Move(6), TurnLeft(3)',
          'REPEAT (1) { Move(3); }'
        ],
        correct: 0,
        expId: 'Pola satu undakan tangga dibungkus ke dalam loop 3 kali untuk menyelesaikan seluruh lintasan.',
        expEn: 'The single stair step pattern is enclosed in a 3-iteration loop to traverse the full path.'
      },
      {
        qId: 'Kode: ULANGI (4) { Maju(2); }. Berapa total langkah maju yang ditempuh karakter?',
        qEn: 'Code: REPEAT (4) { Move(2); }. What is the total number of forward steps taken by the character?',
        optsId: ['4 langkah', '6 langkah', '8 langkah', '10 langkah'],
        optsEn: ['4 steps', '6 steps', '8 steps', '10 steps'],
        correct: 2,
        expId: '4 putaran perulangan dikalikan 2 langkah per putaran menghasilkan total 8 langkah maju.',
        expEn: '4 iterations multiplied by 2 steps per iteration equals 8 total forward steps.'
      },
      {
        qId: 'Mengapa mengenali pola (Pattern Recognition) sangat penting dalam menyusun algoritma perulangan?',
        qEn: 'Why is pattern recognition essential when designing loop algorithms?',
        optsId: [
          'Menemukan bagian instruksi yang berulang sehingga dapat disederhanakan ke dalam struktur loop',
          'Mengubah tampilan grafis permainan',
          'Mengurangi daya baterai perangkat',
          'Menghilangkan kebutuhan akan penulisan kode'
        ],
        optsEn: [
          'Identifying recurring code segments to encapsulate them into clean loop structures',
          'Modifying game graphical themes',
          'Lowering device battery consumption',
          'Eliminating the need to write code'
        ],
        correct: 0,
        expId: 'Pengenalan pola memungkinkan programmer meringkas puluhan instruksi repetitif menjadi satu loop cerdas.',
        expEn: 'Pattern recognition enables developers to condense repetitive sequences into concise loops.'
      },
      {
        qId: 'Monster di ujung jalur memiliki 3 HP. Di depan monster, pemain menulis ULANGI (3) { Serang(); }. Hasilnya?',
        qEn: 'A monster at path end has 3 HP. Facing it, player writes REPEAT (3) { Attack(); }. What is the result?',
        optsId: [
          'Monster diserang 3 kali beruntun hingga 3 HP-nya habis dan kalah',
          'Karakter hanya menyerang 1 kali lalu mundur',
          'Serangan tidak berdampak pada monster',
          'Karakter kehabisan darah'
        ],
        optsEn: [
          'Monster is struck 3 times consecutively, depleting its 3 HP and defeated',
          'Character attacks once and steps backward',
          'Strikes inflict no damage on monster',
          'Character loses all health'
        ],
        correct: 0,
        expId: 'Loop 3 kali mengeksekusi 3 kali tebasan Serang(), menuntaskan seluruh 3 HP monster.',
        expEn: 'A 3-iteration loop runs Attack() 3 times, fully depleting the monster 3 HP.'
      },
      {
        qId: 'Jika karakter mengeksekusi ULANGI (4) { Belok Kiri(); }, apa orientasi arah hadap akhir karakter?',
        qEn: 'If character executes REPEAT (4) { TurnLeft(); }, what is the final orientation direction?',
        optsId: [
          'Sama persis dengan arah hadap semula (putaran 360 derajat)',
          'Berbalik 180 derajat ke belakang',
          'Berbelok 90 derajat ke kanan',
          'Berbelok 90 derajat ke kiri'
        ],
        optsEn: [
          'Identical to the original facing orientation (360-degree rotation)',
          'Reversed 180 degrees backward',
          'Rotated 90 degrees right',
          'Rotated 90 degrees left'
        ],
        correct: 0,
        expId: 'Empat kali putaran 90 derajat ke kiri menghasilkan putaran penuh 360 derajat (kembali ke orientasi awal).',
        expEn: 'Four 90-degree left turns yield a complete 360-degree rotation, restoring original heading.'
      }
    ]
  },

  // -------------------------------------------------------------
  // LEVEL 12: Sulit (Boss Iblis Perulangan & Debugging Loop)
  // -------------------------------------------------------------
  {
    level: 12,
    diffId: 'Sulit',
    diffEn: 'Hard',
    questions: [
      {
        qId: 'Karakter berniat maju 4 petak, tetapi programmer menulis ULANGI (5) { Maju(); } hingga menabrak dinding. Bug ini disebut...',
        qEn: 'Intending to move 4 tiles, programmer writes REPEAT (5) { Move(); } hitting a wall. This bug is known as...',
        optsId: [
          'Off-by-one error (kesalahan kelebihan/kekurangan 1 iterasi)',
          'Syntax error (kesalahan penulisan tata bahasa kode)',
          'Hardware breakdown (kerusakan fisik perangkat keras)',
          'Network disconnection (kehilangan sambungan internet)'
        ],
        optsEn: [
          'Off-by-one error (one iteration too many or too few)',
          'Syntax error (linguistic rule breach in code)',
          'Hardware breakdown (physical component failure)',
          'Network disconnection (loss of online connection)'
        ],
        correct: 0,
        expId: 'Off-by-one error adalah bug logika umum di mana perulangan berjalan satu kali lebih banyak atau lebih sedikit.',
        expEn: 'Off-by-one error is a classic logic bug where a loop iterates one time too many or too few.'
      },
      {
        qId: 'Apa yang dimaksud dengan fenomena "Infinite Loop" (perulangan tak hingga) dalam pemrograman?',
        qEn: 'What is meant by an "Infinite Loop" in computer programming?',
        optsId: [
          'Perulangan yang tidak memiliki kondisi berhenti valid sehingga terus berjalan tanpa henti',
          'Perulangan yang berjalan sangat cepat dalam 1 milidetik',
          'Perulangan yang mematikan aplikasi game secara aman',
          'Perulangan yang hanya memuat angka genap'
        ],
        optsEn: [
          'A loop lacking valid termination conditions, thus running perpetually without end',
          'A loop running ultra-fast within 1 millisecond',
          'A loop that cleanly exits the game application',
          'A loop containing only even integer parameters'
        ],
        correct: 0,
        expId: 'Infinite loop terjadi saat kondisi terminasi perulangan tidak pernah tercapai, membuat program membeku (hang).',
        expEn: 'Infinite loops occur when termination predicates never evaluate to False, freezing the program.'
      },
      {
        qId: 'Kode: ULANGI (3) { Maju(); } Serang();. Kapan perintah Serang() akan dieksekusi?',
        qEn: 'Code: REPEAT (3) { Move(); } Attack();. When will the Attack() command be executed?',
        optsId: [
          'Setelah seluruh 3 kali iterasi Maju() selesai dieksekusi',
          'Bersamaan dengan langkah Maju() pertama',
          'Tiga kali berulang bersamaan dengan Maju()',
          'Sebelum karakter melangkah maju'
        ],
        optsEn: [
          'After all 3 iterations of Move() have completed',
          'Concurrently with the first Move() step',
          'Three times iteratively alongside Move()',
          'Prior to taking any forward steps'
        ],
        correct: 0,
        expId: 'Perintah di luar kurung kurawal loop hanya dijalankan setelah seluruh perulangan tuntas diselesaikan.',
        expEn: 'Statements outside the loop braces are executed only after all loop iterations finish.'
      },
      {
        qId: 'Boss Iblis Perulangan memiliki 3 HP. Kode pemain: ULANGI (2) { Serang(); }. Mengapa Boss belum kalah?',
        qEn: 'Boss Loop Demon has 3 HP. Player code: REPEAT (2) { Attack(); }. Why is the Boss not defeated?',
        optsId: [
          'Karena loop hanya menyerang 2 kali sehingga sisa 1 HP monster belum habis',
          'Karena monster kebal terhadap serangan fisik',
          'Karena karakter menyerang dari arah belakang',
          'Karena Serang() tidak dapat diletakkan di dalam perulangan'
        ],
        optsEn: [
          'Because the loop only strikes twice, leaving 1 HP remaining on the monster',
          'Because the monster is immune to physical strikes',
          'Because the character attacked from the rear angle',
          'Because Attack() cannot be enclosed in a loop'
        ],
        correct: 0,
        expId: 'Jumlah iterasi perulangan harus disesuaikan menjadi 3 agar menghasilkan 3 kali tebasan untuk mengalahkan 3 HP.',
        expEn: 'Iteration count must be adjusted to 3 to deliver 3 strikes to fully deplete 3 HP.'
      },
      {
        qId: 'Bagaimana langkah debugging paling efektif untuk melacak kesalahan pada algoritma perulangan?',
        qEn: 'What is the most effective debugging method to trace flaws in loop algorithms?',
        optsId: [
          'Melakukan penelusuran langkah per langkah (tracing) pada tiap putaran perulangan untuk memeriksa posisi karakter',
          'Menghapus seluruh proyek game dan memasang ulang',
          'Menebak angka acak untuk perulangan',
          'Mematikan layar smartphone'
        ],
        optsEn: [
          'Conducting step-by-step tracing across each iteration to verify character coordinates and states',
          'Wiping the entire game project and reinstalling',
          'Guessing random numbers for iteration counts',
          'Turning off the smartphone screen'
        ],
        correct: 0,
        expId: 'Tracing nilai variabel dan posisi karakter di setiap iterasi adalah teknik baku menemukan bug pada loop.',
        expEn: 'Tracing variable states and character positions per iteration is standard practice for loop debugging.'
      }
    ]
  },

  // -------------------------------------------------------------
  // LEVEL 13: Sangat Sulit (Kombinasi Perulangan dan Percabangan / Nested Logic)
  // -------------------------------------------------------------
  {
    level: 13,
    diffId: 'Sangat Sulit',
    diffEn: 'Very Hard',
    questions: [
      {
        qId: 'Kode: ULANGI (4) { JIKA (Ada Dinding) { Belok Kanan(); } LAINNYA { Maju(); } }. Apa fungsi algoritma ini?',
        qEn: 'Code: REPEAT (4) { IF (Wall Ahead) { TurnRight(); } ELSE { Move(); } }. What does this algorithm do?',
        optsId: [
          'Menelusuri lorong adaptif: jika terhalang dinding berbelok kanan, jika jalan kosong melangkah maju',
          'Membuat karakter selalu menabrak dinding sebanyak 4 kali',
          'Menyerang monster di petak awal',
          'Karakter hanya berdiri diam'
        ],
        optsEn: [
          'Traverses corridors adaptively: turns right if blocked, moves forward if clear',
          'Forces the character to bump into walls 4 times',
          'Attacks monsters at the starting tile',
          'Character remains motionless'
        ],
        correct: 0,
        expId: 'Ini adalah algoritma penelusuran dinding dinamis yang memadukan perulangan dan percabangan secara cerdas.',
        expEn: 'This dynamic wall-following algorithm elegantly combines loops and branching for adaptive navigation.'
      },
      {
        qId: 'Berapa total langkah Maju() pada perulangan bersarang: ULANGI (3) { ULANGI (2) { Maju(); } }?',
        qEn: 'What is the total number of Move() steps in nested loops: REPEAT (3) { REPEAT (2) { Move(); } }?',
        optsId: ['3 langkah', '5 langkah', '6 langkah', '9 langkah'],
        optsEn: ['3 steps', '5 steps', '6 steps', '9 steps'],
        correct: 2,
        expId: 'Loop luar berjalan 3 kali, dan tiap putaran loop dalam menjalankan 2 kali Maju(). Total = 3 x 2 = 6 langkah.',
        expEn: 'Outer loop iterates 3 times; each time inner loop runs Move() twice. Total = 3 x 2 = 6 steps.'
      },
      {
        qId: 'Pada struktur SELAMA (Monster Masih Hidup) { Serang(); }, kapan perulangan ini akan berhenti?',
        qEn: 'In a WHILE (Monster Is Alive) { Attack(); } structure, when will the loop terminate?',
        optsId: [
          'Seketika saat kondisi bernilai Salah, yaitu ketika HP monster mencapai 0',
          'Setelah 100 detik berlalu',
          'Hanya saat pemain menekan tombol keluar',
          'Tidak akan pernah berhenti'
        ],
        optsEn: [
          'Instantly when the condition evaluates to False, namely when monster HP reaches 0',
          'After 100 seconds elapse',
          'Only when player taps exit',
          'Will never terminate'
        ],
        correct: 0,
        expId: 'Perulangan bersyarat (while loop) otomatis berhenti saat kondisi prasyaratnya tidak lagi bernilai Benar.',
        expEn: 'A conditional loop (while loop) terminates as soon as its prerequisite condition evaluates to False.'
      },
      {
        qId: 'Mengapa memadukan perulangan dan percabangan (Nested Logic) sangat efektif menyelesaikan labirin rumit?',
        qEn: 'Why is combining loops and branching (Nested Logic) powerful for complex maze resolution?',
        optsId: [
          'Memungkinkan karakter memeriksa lingkungan dan mengambil keputusan berbeda di setiap langkah perulangan',
          'Membuat ukuran file game menjadi lebih besar',
          'Menghilangkan keharusan menyusun strategi langkah',
          'Membuat monster tidak bisa bergerak'
        ],
        optsEn: [
          'Allows the character to inspect surroundings and take distinct decisions on every iteration',
          'Enlarges the game storage footprint',
          'Eliminates the need for tactical route planning',
          'Freezes monsters from acting'
        ],
        correct: 0,
        expId: 'Kombinasi loop dan percabangan memberikan kecerdasan adaptif agar algoritma dapat menavigasi berbagai rintangan.',
        expEn: 'Combining loops and conditionals gives algorithms adaptive intelligence to overcome obstacles.'
      },
      {
        qId: 'Jika di dalam suatu perulangan kondisi JIKA selalu bernilai Salah (False), bagian mana yang dieksekusi?',
        qEn: 'If inside a loop an IF condition always evaluates to False, which portion executes?',
        optsId: [
          'Bagian LAINNYA (Else) jika ada, atau lanjut ke instruksi berikutnya di dalam loop',
          'Seluruh perulangan otomatis dibatalkan',
          'Program langsung mematikan aplikasi',
          'Karakter kembali ke titik awal'
        ],
        optsEn: [
          'The ELSE block if present, or continuing to subsequent statements in the loop',
          'The entire loop is cancelled immediately',
          'The program terminates the application',
          'The character teleports to the start'
        ],
        correct: 0,
        expId: 'Saat cabang If bernilai False, kendali dialihkan ke cabang Else (jika disediakan) tanpa membatalkan loop.',
        expEn: 'When an IF branch evaluates to False, control shifts to the ELSE branch without aborting the loop.'
      }
    ]
  },

  // -------------------------------------------------------------
  // LEVEL 14: Sangat Sulit (Pelacakan Koordinat & Tracing Algoritma Kompleks)
  // -------------------------------------------------------------
  {
    level: 14,
    diffId: 'Sangat Sulit',
    diffEn: 'Very Hard',
    questions: [
      {
        qId: 'Mulai di (1,1) hadap Timur. Dijalankan: Maju(2), Belok Kanan(), Maju(3). Di koordinat mana karakter berada?',
        qEn: 'Start at (1,1) facing East. Executed: Move(2), TurnRight(), Move(3). What is the final coordinate?',
        optsId: ['(4, 3)', '(3, 4)', '(1, 4)', '(2, 5)'],
        optsEn: ['(4, 3)', '(3, 4)', '(1, 4)', '(2, 5)'],
        correct: 0,
        expId: 'Dari (row 1, col 1) hadap Timur maju 2 -> col jadi 3 (1,3). Belok kanan hadap Selatan, maju 3 -> row bertambah 3 jadi 4. Posisi akhir: (4,3).',
        expEn: 'From (1,1) facing East move 2 -> col is 3 (1,3). Turn right facing South, move 3 -> row adds 3 to 4. Final: (4,3).'
      },
      {
        qId: 'Karakter menghadap Utara: Belok Kanan(), Belok Kanan(), Belok Kiri(). Ke arah mana karakter sekarang menghadap?',
        qEn: 'Character faces North: TurnRight(), TurnRight(), TurnLeft(). Which direction does it face now?',
        optsId: ['Timur', 'Barat', 'Selatan', 'Utara'],
        optsEn: ['East', 'West', 'South', 'North'],
        correct: 0,
        expId: 'Utara -> belok kanan jadi Timur -> belok kanan jadi Selatan -> belok kiri berlawanan jarum jam jadi Timur.',
        expEn: 'North -> turn right faces East -> turn right faces South -> turn left counter-clockwise faces East.'
      },
      {
        qId: 'Algoritma A membutuhkan 12 blok terpisah. Algoritma B menggunakan 1 loop 4 blok dengan hasil sama persis. Mengapa B lebih baik?',
        qEn: 'Algorithm A uses 12 separate blocks. Algorithm B uses 1 loop of 4 blocks with identical outcome. Why is B superior?',
        optsId: [
          'Algoritma B lebih modular, menghemat kuota blok par, dan mudah dirawat jika terjadi perubahan',
          'Karena Algoritma B ditulis dengan huruf tebal',
          'Karena Algoritma A tidak dapat dijalankan oleh komputer',
          'Tidak ada perbedaan keunggulan antara keduanya'
        ],
        optsEn: [
          'Algorithm B is modular, conserves par block budget, and is easy to maintain',
          'Because Algorithm B is rendered in bold font',
          'Because Algorithm A cannot be run by computers',
          'There is no difference in quality between the two'
        ],
        correct: 0,
        expId: 'Efisiensi algoritma diukur dari kesederhanaan, keterbacaan, dan efisiensi konsumsi kuota blok.',
        expEn: 'Algorithm efficiency is measured by simplicity, readability, and concise block quota utilization.'
      },
      {
        qId: 'Pada labirin 11x11, apa prinsip utama penentuan jalur optimal dari petak awal (1,1) ke monster (9,9)?',
        qEn: 'In an 11x11 maze, what is the core principle for optimal pathfinding from (1,1) to monster (9,9)?',
        optsId: [
          'Memilih rute terpendek yang meminimalkan belokan sia-sia dan menghindari lorong buntu',
          'Melangkah secara acak tanpa rencana',
          'Menabrak dinding sebanyak mungkin',
          'Berputar di tempat awal'
        ],
        optsEn: [
          'Selecting the shortest route that minimizes redundant turns and avoids dead ends',
          'Stepping randomly without prior calculation',
          'Colliding with walls as often as possible',
          'Spinning in place at the start'
        ],
        correct: 0,
        expId: 'Pencarian rute optimal berfokus pada jarak terpendek (BFS) dan efisiensi pergerakan tanpa langkah mubazir.',
        expEn: 'Optimal pathfinding focuses on shortest paths (BFS) and motion efficiency without redundant steps.'
      },
      {
        qId: 'Dalam pelacakan kesalahan (debugging) algoritma kompleks multi-tahap, apa langkah awal yang paling bijak?',
        qEn: 'In debugging multi-stage complex algorithms, what is the wisest initial diagnostic step?',
        optsId: [
          'Mengisolasi titik pertama di mana karakter mulai menyimpang dari rute yang direncanakan',
          'Mengulang-ulang eksekusi tanpa mengubah kode',
          'Menghapus seluruh proyek game',
          'Menambahkan perintah acak'
        ],
        optsEn: [
          'Isolating the initial point where character behavior diverged from planned trajectory',
          'Repeatedly executing unchanged code',
          'Deleting the entire game project',
          'Adding random commands'
        ],
        correct: 0,
        expId: 'Mengisolasi lokasi pertama munculnya bug memungkinkan perbaikan tepat sasaran tanpa merusak bagian lain.',
        expEn: 'Isolating the earliest divergence point enables targeted fixes without disturbing valid code logic.'
      }
    ]
  },

  // -------------------------------------------------------------
  // LEVEL 15: Sangat Sulit (Final Boss Behemoth Logika & Master Algoritma)
  // -------------------------------------------------------------
  {
    level: 15,
    diffId: 'Sangat Sulit',
    diffEn: 'Very Hard',
    questions: [
      {
        qId: 'Final Boss Behemoth Logika memiliki 4 HP. Setelah berhadapan langsung, blok penutup yang tepat untuk menang adalah...',
        qEn: 'Final Boss Logic Behemoth has 4 HP. Facing it directly, what is the proper closing block to claim victory?',
        optsId: [
          'ULANGI (4) { Serang(); }',
          'Maju(4)',
          'ULANGI (2) { Maju(); }',
          'Belok Kanan(4)'
        ],
        optsEn: [
          'REPEAT (4) { Attack(); }',
          'Move(4)',
          'REPEAT (2) { Move(); }',
          'TurnRight(4)'
        ],
        correct: 0,
        expId: 'Empat kali serangan beruntun menggunakan ULANGI (4) menuntaskan seluruh 4 HP Behemoth Logika dan menamatkan game!',
        expEn: 'Four consecutive strikes via REPEAT (4) completely deplete Behemoth 4 HP and beat the game!'
      },
      {
        qId: 'Rangkaian: 1. Inisialisasi rute -> 2. Perulangan navigasi -> 3. Percabangan rintangan -> 4. Serangan pemungkas. Tahapan ini mencerminkan...',
        qEn: 'Sequence: 1. Path init -> 2. Nav loop -> 3. Branching check -> 4. Final strike. This workflow exemplifies...',
        optsId: [
          'Rekayasa algoritma terpadu dan computational thinking komprehensif',
          'Pemikiran spekulatif tanpa pembuktian ilmiah',
          'Animasi grafis tanpa ada aturan logika',
          'Permainan tebak-tebakan acak'
        ],
        optsEn: [
          'Integrated algorithm engineering and comprehensive computational thinking',
          'Speculative guessing without systematic logic',
          'Graphical animations without underlying logic rules',
          'Random trial and error'
        ],
        correct: 0,
        expId: 'Menggabungkan seluruh pilar algoritma dari Level 1 sampai 15 adalah bukti penguasaan computational thinking tingkat tinggi.',
        expEn: 'Synthesizing all algorithmic pillars across Levels 1-15 demonstrates advanced computational mastery.'
      },
      {
        qId: 'Mengapa menjaga efisiensi langkah par saat melawan Boss Level 15 sangat penting?',
        qEn: 'Why is preserving step par efficiency against Boss Level 15 essential?',
        optsId: [
          'Untuk menghindari pinalti tabrakan dinding dan meraih 3 bintang prestasi sempurna',
          'Supaya monster tidak dapat kabur',
          'Karena dinding labirin dapat bergerak',
          'Agar karakter dapat melompati arena'
        ],
        optsEn: [
          'To avoid collision penalties and secure a flawless 3-star achievement rating',
          'To prevent the monster from escaping',
          'Because maze walls are moving obstacles',
          'To let the character leap over the arena'
        ],
        correct: 0,
        expId: 'Meminimalkan langkah di bawah batas par membuktikan solusi algoritma pemain merupakan yang paling optimal.',
        expEn: 'Minimizing steps within par confirms that the player algorithmic solution is mathematically optimal.'
      },
      {
        qId: 'Apa kesimpulan esensial dari pembelajaran logika pemrograman di seluruh 15 level AlgoQuest?',
        qEn: 'What is the core takeaway of programming logic learned across all 15 AlgoQuest levels?',
        optsId: [
          'Algoritma adalah seni menyusun instruksi logis, terstruktur, dan efisien untuk memecahkan masalah langkah demi langkah',
          'Pemrograman hanya sekadar menghafal tombol',
          'Komputer dapat bekerja sendiri tanpa instruksi manusia',
          'Urutan perintah tidak mempengaruhi hasil teknologi'
        ],
        optsEn: [
          'Algorithms are the art of crafting logical, structured, and efficient instructions to solve problems step by step',
          'Programming is merely memorizing button labels',
          'Computers work autonomously without human guidance',
          'Command sequencing has no real-world technical impact'
        ],
        correct: 0,
        expId: 'Algoritma adalah fondasi pemecahan masalah sistematis yang mengubah ide logis menjadi karya teknologi nyata.',
        expEn: 'Algorithms are the bedrock of systematic problem-solving that translates logical ideas into technological reality.'
      },
      {
        qId: 'Selamat telah menaklukkan Behemoth Logika! Apa gelar kehormatan tertinggi bagi pemain yang menyelesaikan Level 15?',
        qEn: 'Congratulations on slaying Logic Behemoth! What is the supreme title for beating Level 15?',
        optsId: [
          'Master Logika (Logic Master)',
          'Pemula Labirin',
          'Goblin Magang',
          'Pengamat Hutan'
        ],
        optsEn: [
          'Logic Master',
          'Maze Beginner',
          'Apprentice Goblin',
          'Forest Spectator'
        ],
        correct: 0,
        expId: 'Menuntaskan seluruh 15 level dan kuis komputasi mengukuhkan pemain sebagai Master Logika sejati!',
        expEn: 'Completing all 15 levels and computing quizzes establishes the player as a true Logic Master!'
      }
    ]
  }
];

function escapeDart(str) {
  return str.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\$/g, '\\$');
}

let out = `// ============================================================
// SOAL LOGIKA — KUIS 15 LEVEL (75 PERTANYAAN)
// ============================================================
// Setiap level dari Level 1 sampai 15 memiliki 5 soal khusus
// dengan 4 pilihan ganda (A, B, C, D) dan 1 jawaban benar.
// Tingkat kesulitan bertingkat:
//   Level 1-3: Pemula
//   Level 4-6: Mudah menuju menengah
//   Level 7-9: Menengah
//   Level 10-12: Sulit
//   Level 13-15: Sangat sulit

class QuizQuestion {
  final String questionId;
  final String questionEn;

  /// Pilihan jawaban (tepat 4 opsi: A, B, C, D).
  final List<String> optionsId;
  final List<String> optionsEn;

  /// Index jawaban benar (0-based: 0=A, 1=B, 2=C, 3=D).
  final int correct;

  /// Penjelasan edukatif setelah menjawab.
  final String explanationId;
  final String explanationEn;

  const QuizQuestion({
    required this.questionId,
    required this.questionEn,
    required this.optionsId,
    required this.optionsEn,
    required this.correct,
    required this.explanationId,
    required this.explanationEn,
  });

  String question(bool en) => en ? questionEn : questionId;
  List<String> options(bool en) => en ? optionsEn : optionsId;
  String explanation(bool en) => en ? explanationEn : explanationId;
}

class LevelQuizSet {
  final int levelNumber; // 1..15
  final String difficultyId;
  final String difficultyEn;
  final List<QuizQuestion> questions; // 5 soal

  const LevelQuizSet({
    required this.levelNumber,
    required this.difficultyId,
    required this.difficultyEn,
    required this.questions,
  });

  String difficulty(bool en) => en ? difficultyEn : difficultyId;
}

class QuizCatalog {
  QuizCatalog._();

  static const int totalLevels = 15;
  static const int questionsPerLevel = 5;
  static int get totalQuestions => totalLevels * questionsPerLevel;

  static List<QuizQuestion> get questions =>
      allLevels.expand((LevelQuizSet s) => s.questions).toList();

  static LevelQuizSet getLevelQuiz(int globalLevel) {
    final int idx = (globalLevel - 1).clamp(0, totalLevels - 1);
    return allLevels[idx];
  }

  static LevelQuizSet getQuizByRegionAndLevel(int region, int level) {
    final int r = region.clamp(0, 4);
    final int l = level.clamp(0, 2);
    final int globalLevel = r * 3 + l + 1;
    return getLevelQuiz(globalLevel);
  }

  /// Kompatibilitas mundur jika dipanggil dari modul lama
  static QuizQuestion question(int region, int level) {
    return getQuizByRegionAndLevel(region, level).questions.first;
  }

  static const List<LevelQuizSet> allLevels = <LevelQuizSet>[
`;

for (const set of quizData) {
  out += `    // ========================================================\n`;
  out += `    // LEVEL ${set.level} — ${set.diffId.toUpperCase()} (${set.diffEn.toUpperCase()})\n`;
  out += `    // ========================================================\n`;
  out += `    LevelQuizSet(\n`;
  out += `      levelNumber: ${set.level},\n`;
  out += `      difficultyId: '${escapeDart(set.diffId)}',\n`;
  out += `      difficultyEn: '${escapeDart(set.diffEn)}',\n`;
  out += `      questions: <QuizQuestion>[\n`;

  for (const q of set.questions) {
    out += `        QuizQuestion(\n`;
    out += `          questionId: '${escapeDart(q.qId)}',\n`;
    out += `          questionEn: '${escapeDart(q.qEn)}',\n`;
    out += `          optionsId: <String>[\n`;
    for (const opt of q.optsId) {
      out += `            '${escapeDart(opt)}',\n`;
    }
    out += `          ],\n`;
    out += `          optionsEn: <String>[\n`;
    for (const opt of q.optsEn) {
      out += `            '${escapeDart(opt)}',\n`;
    }
    out += `          ],\n`;
    out += `          correct: ${q.correct},\n`;
    out += `          explanationId: '${escapeDart(q.expId)}',\n`;
    out += `          explanationEn: '${escapeDart(q.expEn)}',\n`;
    out += `        ),\n`;
  }

  out += `      ],\n`;
  out += `    ),\n\n`;
}

out += `  ];\n`;
out += `}\n`;

const targetPath = path.join(__dirname, '..', 'lib', 'services', 'quiz_service.dart');
fs.writeFileSync(targetPath, out, 'utf8');
console.log(`Generated ${quizData.length} levels (75 questions) to ${targetPath}`);
