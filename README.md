# HR Employee Attrition Analysis

Analisis mendalam terhadap faktor-faktor yang berasosiasi dengan keputusan karyawan untuk keluar dari perusahaan (attrition), menggunakan pendekatan gabungan **database design (MySQL)**, **uji statistik**, dan **logistic regression (Python)**. Proyek ini merupakan bagian kedua dari rangkaian portofolio Data Analyst, dengan MySQL berperan sebagai tools utama — menunjukkan kemampuan merancang skema relasional dari data flat, di samping analisis statistik dan machine learning di Python.

Dari 1.470 karyawan dengan attrition rate keseluruhan **16,12%**, ditemukan bahwa kombinasi *overtime*, penghasilan rendah, dan rendahnya kepuasan kerja menghasilkan kelompok karyawan dengan attrition rate **65,91%** — lebih dari 4 kali lipat rata-rata perusahaan.

## Business Questions

1. Berapa attrition rate keseluruhan dan breakdown-nya per departemen, job role, dan job level?
2. Apakah overtime berkorelasi signifikan dengan attrition?
3. Apakah kompensasi (monthly income, salary hike, stock option) berbeda antara karyawan yang keluar vs bertahan?
4. Bagaimana pengaruh tenure & career stagnation terhadap attrition?
5. Bagaimana pengaruh kepuasan kerja terhadap attrition?
6. Profil risiko tinggi seperti apa yang terbentuk dari kombinasi faktor-faktor di atas?

## Dataset

[IBM HR Analytics Employee Attrition & Performance](https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset/data) (Kaggle) — data demografis, kompensasi, tenure, dan skor kepuasan kerja, mencakup 1.470 baris karyawan dengan 35 kolom, berbentuk 1 tabel flat.

## Tools & Workflow

| Tahap | Tools | Deliverable |
|---|---|---|
| Data cleaning & normalisasi | Python (pandas) | Jupyter Notebook |
| Database design & business query | MySQL | Schema SQL + query file (window functions) |
| Uji statistik & modeling | Python (scipy, statsmodels, scikit-learn) | Jupyter Notebook (Chi-Square, Mann-Whitney U, Logistic Regression) |

**Alur kerja saya:** Python (cleaning + normalisasi data flat menjadi 6 tabel relasional) → MySQL (schema design + load data + business query Q1) → Python (uji statistik Q2-Q5 + logistic regression Q6).

## Struktur Database

Data flat asli dipecah menjadi 6 tabel relasional:

- `departments`, `job_roles`, `education_fields` — tabel dimensi
- `employees` — tabel inti (demografis, karier, foreign key ke 3 tabel dimensi)
- `compensation` — data gaji & kompensasi (relasi 1:1 dengan employees)
- `satisfaction_scores` — data survei kepuasan (relasi 1:1 dengan employees)

Catatan desain: `job_roles` sengaja tidak memiliki foreign key ke `departments`, karena ditemukan job role "Manager" tersebar di 3 departemen berbeda (Sales, R&D, HR).

## Key Insights

### Q1 — Attrition Rate Breakdown

- Attrition rate tertinggi per **departemen**: Sales (20,63%) > HR (19,05%) > R&D (13,84%)
- Namun secara **volume**, R&D level 1 menyumbang **42,62%** dari seluruh karyawan yang keluar — jauh melampaui kontribusi kelompok manapun, meski rate-nya bukan yang tertinggi. Kontributor tunggal terbesar: **Laboratory Technician level 1** (23,63% dari total leavers), diikuti **Research Scientist level 1** (18,99%)
- **Sales Representative** memiliki rate tertinggi di antara semua job role (39,76%, naik jadi 42,11% saat dipersempit ke level 1) — lebih dari 2x rata-rata perusahaan
- Pola job level tidak linear: turun tajam dari level 1 (26,34%) ke level 2 (9,74%), tapi naik lagi di level 3 dan 5 — mengindikasikan sub-grup senior yang juga rentan keluar

### Q2 — Overtime

Karyawan overtime memiliki attrition rate **30,53%**, hampir 3x lipat dibanding non-overtime (**10,44%**). Chi-Square test mengonfirmasi asosiasi signifikan (p < 0,0001), dengan kekuatan asosiasi antara lemah hingga sedang (Cramer's V = 0,2441).

### Q3 — Kompensasi

- **Monthly income**: median karyawan yang keluar (3.202) jauh lebih rendah dari yang bertahan (5.204) — signifikan (p < 0,0001), effect size mendekati moderate (rank-biserial = 0,3113)
- **Stock option level**: signifikan (p < 0,0001), effect size lemah-sedang (0,2498)
- **Percent salary hike**: tidak signifikan (p = 0,3655) — besaran kenaikan gaji tahunan bukan faktor pembeda

### Q4 — Tenure & Career Stagnation

- **Years at company** dan **years with current manager** signifikan (p < 0,0001), effect size lemah-sedang (0,2979 dan 0,2720) — karyawan yang keluar cenderung di masa-masa awal bekerja
- **Years since last promotion** signifikan secara statistik namun tipis (p = 0,0412) dengan effect size sangat kecil (0,0803) — kemungkinan besar signifikansi ini didorong ukuran sampel besar, bukan efek praktis yang berarti
- Ketiga variabel tenure saling berkorelasi tinggi (0,51-0,77), mengindikasikan tumpang tindih informasi
- Variabel turunan `rasio_years` (proporsi masa kerja tanpa promosi) tidak terbukti berasosiasi dengan attrition (p = 0,8168)

### Q5 — Kepuasan Kerja

- **Job involvement** memiliki efek paling kuat (p < 0,0001, rank-biserial = 0,1653): attrition rate turun dari 33,73% (level 1) ke 9,03% (level 4)
- **Job satisfaction** dan **environment satisfaction** juga signifikan (p < 0,0001 dan p = 0,0002)
- **Work-life balance** signifikan tapi tipis (p = 0,0465), dengan pola tidak linear
- **Relationship satisfaction** tidak signifikan (p = 0,1020)
- Kelima variabel kepuasan praktis tidak saling berkorelasi (-0,02 hingga 0,03) — mengukur dimensi yang berbeda-beda, bukan "rasa puas" tunggal

### Q6 — Profil Risiko Tinggi

Logistic regression (dengan `class_weight='balanced'` untuk menangani data tidak seimbang) mengidentifikasi `over_time`, `monthly_income`, dan `job_satisfaction` sebagai fitur paling stabil dan berpengaruh. Uji VIF mengonfirmasi korelasi moderate antar variabel tenure (VIF tertinggi 4,28, di bawah ambang kritis 5), yang menjelaskan mengapa urutan pengaruh `years_at_company` dan `years_since_last_promotion` berubah signifikan dibanding hasil univariate di Q4.

**Dua profil risiko tinggi dibangun:**

1. **Kombinasi aturan sederhana** (overtime + penghasilan di bawah kuartil 1 + job satisfaction rendah): 44 karyawan (3% dari total) dengan attrition rate **65,91%** — lebih dari 4x rata-rata perusahaan
2. **Segmentasi berbasis probabilitas model**: seluruh karyawan terbagi dalam spektrum risiko dari 3,40% (risiko terendah) hingga 56,46% (risiko tertinggi), dengan pola yang konsisten di seluruh fitur pendukung (over_time rate, monthly income, job satisfaction)

## Ringkasan Performa Model

| Metrik | Train | Test |
|---|---|---|
| Accuracy | 0,75 | 0,73 |
| Recall (attrition = Yes) | 0,76 | 0,69 |
| Precision (attrition = Yes) | 0,36 | 0,34 |

Model diprioritaskan untuk recall tinggi pada kelas minoritas (attrition), karena secara bisnis gagal mendeteksi karyawan berisiko keluar (false negative) dianggap lebih mahal konsekuensinya dibanding false alarm.

## Metodologi Analisis

### Data Cleaning & Normalisasi (Python)
- Membuang 3 kolom konstan yang tidak informatif (`EmployeeCount`, `StandardHours`, `Over18`)
- Memecah 1 tabel flat menjadi 6 tabel relasional (3 tabel dimensi + `employees`, `compensation`, `satisfaction_scores`)
- Validasi hasil normalisasi memastikan jumlah baris konsisten di seluruh tabel (1.470 karyawan)

### Database Design (MySQL)
Skema dirancang dengan mempertimbangkan functional dependency — `job_roles` sengaja tidak diberi foreign key ke `departments`, karena ditemukan job role "Manager" tersebar di 3 departemen berbeda (bukan relasi 1-ke-banyak yang bersih).

### Uji Statistik (Python)
- **Chi-Square Test of Independence** untuk variabel kategorikal-kategorikal (overtime vs attrition)
- **Mann-Whitney U Test + Rank-Biserial Correlation** untuk variabel numerik/ordinal vs attrition (kompensasi, tenure, kepuasan kerja) — dipilih karena data tidak berdistribusi normal
- **Variance Inflation Factor (VIF)** untuk mengecek multikolinearitas sebelum modeling

### Logistic Regression & Profil Risiko (Python)
Model dengan `class_weight='balanced'` untuk menangani data tidak seimbang (attrition 16,12% vs 83,88%). Profil risiko tinggi dibangun dengan dua pendekatan: kombinasi aturan sederhana dari fitur ber-koefisien tertinggi, dan segmentasi berbasis probabilitas prediksi model.

## Keterbatasan Analisis

- Dataset bersifat **cross-sectional** (potret satu waktu), sehingga seluruh hasil menunjukkan **asosiasi**, bukan hubungan sebab-akibat
- Beberapa kombinasi kelompok kecil (n < 15) pada breakdown Q1 berisiko kurang stabil dan sebaiknya dibaca sebagai indikasi awal, bukan kesimpulan final
- Korelasi antar variabel tenure membuat interpretasi koefisien individual pada `years_at_company` dan `years_since_last_promotion` di model Q6 perlu dibaca hati-hati; hasil univariate (Q4) lebih dapat diandalkan untuk masing-masing variabel secara terpisah

## Struktur Repository

```
HR-Employee-Attrition-Analysis/
├── README.md
├── .env.example
├── .gitignore
├── notebooks/
│   ├── 01_data_preparation_HR.ipynb
│   ├── 04_overtime_attrition_analysis.ipynb
│   ├── 05_compensation_attrition_analysis.ipynb
│   ├── 06_tenure_attrition_analysis.ipynb
│   ├── 07_satisfaction_attrition_analysis.ipynb
│   └── 08_profile_attrition_analysis.ipynb
├── sql/
│   ├── 02_HR_attrition_schema.sql
│   └── 03_HR_attrition_rate_analysis.sql
└── data/
    └── normalized_csv/
```

> Catatan: Dataset dapat diunduh langsung dari [link Kaggle di atas](https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset/data).

---

## Kontak

**Ahmad Fadillah Firdaus**
ahmadfadillahfirdaus@gmail.com | [LinkedIn](https://www.linkedin.com/in/ahmadfadillahfirdaus/) | [GitHub](https://github.com/Dodolodil)
