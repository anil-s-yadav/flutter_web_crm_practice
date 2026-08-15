const pool = require('../config/db');

async function setupLearningTable() {
  try {
    console.log('Setting up learning_topics table...');
    
    await pool.execute(`
      CREATE TABLE IF NOT EXISTS learning_topics (
        id VARCHAR(50) PRIMARY KEY,
        category ENUM('salesPitch', 'objectionHandling', 'serviceScope', 'sourcingVerification', 'fieldSop') NOT NULL,
        title VARCHAR(255) NOT NULL,
        subtitle VARCHAR(255) NOT NULL,
        target_role ENUM('all', 'sales', 'sourcing', 'executive', 'admin') DEFAULT 'all',
        script_english TEXT,
        script_hindi TEXT,
        key_tip TEXT,
        bullet_points JSON,
        tags JSON,
        order_index INT DEFAULT 0,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);

    const topics = [
      {
        id: 'LRN001',
        category: 'salesPitch',
        title: 'Initial Client Call & Requirement Discovery',
        subtitle: 'How to greet client, discover exact household needs, and establish trust',
        target_role: 'sales',
        script_english: 'Hello [Client Name], this is [My Name] calling from Verified Maids. I understand you are looking for an experienced [Cook / House Maid / Babysitter] in [Locality]. Could you please share the daily shift timings, family size, and primary tasks required?',
        script_hindi: 'Namaste [Client Name] ji! Main [My Name], Verified Maids se baat kar raha hoon. Humein aapki inquiry mili thi for [Cook / House Maid / Babysitter] in [Locality]. Aapke yahan daily shift timings kya rahenge, family size kitni hai, aur main tasks kya rahenge?',
        key_tip: 'Always confirm shift timings (10h, 12h, or 24h Live-in) and dietary preferences before quoting salary estimates.',
        bullet_points: JSON.stringify([
          'Listen actively without interrupting the client.',
          'Confirm key parameters: Shift hours, dietary habits (Veg/Non-Veg), family size, location.',
          'Never commit to unrealistic low budgets—quote realistic market salary.',
          'Log clear call notes in CRM immediately after hanging up.'
        ]),
        tags: JSON.stringify(['Sales Pitch', 'Initial Call', 'Hindi', 'English', 'Discovery']),
        order_index: 1
      },
      {
        id: 'LRN002',
        category: 'salesPitch',
        title: 'Explaining Placement Fee & 2-Installments Structure',
        subtitle: 'How to explain the 1-month agency fee + 18% GST in 2 installments clearly and confidently',
        target_role: 'sales',
        script_english: 'Our placement fee is a one-time charge for a complete 1-year contract, equal to 1 month of the candidate\'s agreed salary + 18% GST. To make it convenient for you, we divide it into 2 easy installments: 50% upon shortlisting and trial confirmation, and the remaining 50% only when the candidate joins permanently.',
        script_hindi: 'Hamari agency placement fee pure 1 saal ke contract ke liye one-time charge hoti hai, jo candidate ki 1 month salary + 18% GST ke barabar hai. Isme aapko pura amount ek sath nahi dena hota—hum ise 2 aasan installments me divide karte hain: 50% candidate shortlist aur trial confirm hone par, aur baki 50% candidate ke final join karne par.',
        key_tip: 'Clearly emphasize that monthly salary goes directly to the candidate each month, and the agency fee is only charged once a year.',
        bullet_points: JSON.stringify([
          '1st Installment (50%): Payable on Shortlisting or upon Candidate Drop by Field Executive.',
          '2nd Installment (50%): Payable on Final Joining & Contract Execution.',
          'Doorstep Payment Flexibility: If client is hesitant to pay online, offer "Pay on Drop to Field Executive".',
          '100% Tax Compliant: Legitimate GST invoice provided for all payments.'
        ]),
        tags: JSON.stringify(['Sales Pitch', 'Pricing', '2 Installments', 'Pay on Drop', 'GST', 'Hindi', 'English']),
        order_index: 2
      },
      {
        id: 'LRN003',
        category: 'objectionHandling',
        title: 'Objection: "Why is there 18% GST on the agency fee?"',
        subtitle: 'How to address GST questions while emphasizing legal safety and compliance',
        target_role: 'sales',
        script_english: 'We are a 100% legally registered staffing company. The 18% GST is a statutory government tax that ensures you receive a formal tax invoice, legally binding contract, and police verification record safeguarding your family.',
        script_hindi: 'Sir/Ma\'am, Verified Maids ek 100% government-registered company hai. 18% GST statutory tax hai jisse aapko proper tax invoice milta hai, legally binding contract milta hai, aur complete police verification record maintain hota hai for family safety.',
        key_tip: 'Focus on safety, legitimacy, and documentation. Local unregistered brokers vanish, but Verified Maids provides full legal traceability.',
        bullet_points: JSON.stringify([
          'Highlight government compliance and formal tax invoice.',
          'Compare with unorganized brokers who offer zero legal recourse or safety.',
          'Mention that GST is charged only on our agency service fee, not on candidate monthly salary.'
        ]),
        tags: JSON.stringify(['Objections', 'GST', 'Tax', 'Hindi', 'English']),
        order_index: 3
      },
      {
        id: 'LRN004',
        category: 'objectionHandling',
        title: 'Objection: "What if the maid leaves after a few weeks or takes sudden leave?"',
        subtitle: 'How to reassure the client about the 100% free candidate replacement guarantee',
        target_role: 'sales',
        script_english: 'Under our 1-year contract, you receive a 100% free candidate replacement guarantee. If for any reason the candidate leaves or their work does not meet your expectations, our sourcing team will assign a verified replacement without any additional agency fee.',
        script_hindi: 'Aapko hamare 1-year contract ke andar 100% free replacement guarantee milti hai. Agar kisi bhi karan se candidate chhod kar chali jati hai ya kaam pasand nahi aata, toh hamari sourcing team bina kisi extra agency charge ke new verified candidate provide karti hai.',
        key_tip: 'Give the client peace of mind by explaining our large pre-screened pool of Ready-to-Place candidates.',
        bullet_points: JSON.stringify([
          'Contract includes free replacement guarantee within the validity period.',
          'Replacements are pre-vetted with background verification.',
          'Dedicated Relationship Manager assigned to assist immediately upon request.'
        ]),
        tags: JSON.stringify(['Objections', 'Replacement', 'Guarantee', 'Hindi', 'English']),
        order_index: 4
      },
      {
        id: 'LRN005',
        category: 'objectionHandling',
        title: 'Objection: "Local street brokers take much less fee"',
        subtitle: 'How to differentiate Verified Maids from unregistered local brokers',
        target_role: 'sales',
        script_english: 'Local brokers do not conduct 12-digit Aadhaar verification, past employment checks, or police clearance assistance. If their maid leaves in 10 days, they switch off their phones. At Verified Maids, your home security is protected by verified background checks and a dedicated corporate support team.',
        script_hindi: 'Sir/Ma\'am, local brokers na toh 12-digit Aadhaar verify karte hain, na police record check karate hain, aur na hi koi legal contract dete hain. Agar maid 10 din me chali jaye toh phone switch off ho jata hai. Verified Maids me aapki family security ke liye thorough background verification, legal contract, aur dedicated relationship manager hota hai.',
        key_tip: 'Never badmouth competitors directly; focus on the premium security, safety, and reliability Verified Maids delivers.',
        bullet_points: JSON.stringify([
          'Unique 12-digit Aadhaar identity vetting.',
          'Police verification assistance.',
          'Formal written contract with replacement clauses.',
          'Corporate accountability and CRM ticket resolution.'
        ]),
        tags: JSON.stringify(['Objections', 'Local Brokers', 'Value Proposition', 'Hindi', 'English']),
        order_index: 5
      },
      {
        id: 'LRN006',
        category: 'serviceScope',
        title: '8 Standard Services Scope & Duty Boundaries',
        subtitle: 'Exact breakdown of duties for House Maid, Cook, Babysitter, Nanny, Japa Maid, Patient Care, Elderly Care, Driver',
        target_role: 'all',
        script_english: 'Let me explain the exact job profile: [Explain selected service inclusions]. This ensures clear expectations between you and the candidate from day one.',
        script_hindi: 'Main aapko is service ki exact duty profile bata deta/deti hoon: [Explain selected service duties]. Isse client aur candidate dono ke beech clear understanding bani rehti hai.',
        key_tip: 'Never mix unrelated roles without client & candidate consent (e.g. asking a dedicated Cook to do heavy deep cleaning or bathroom washing).',
        bullet_points: JSON.stringify([
          'House Maid: Sweeping, mopping, utensil cleaning, dusting, laundry & ironing.',
          'Cook: Daily breakfast/lunch/dinner, meal planning, kitchen hygiene, grocery list.',
          'Babysitter: Infant/toddler feeding, bottle sterilization, playtime, safety supervision.',
          'Nanny: Full-day child care, school homework help, nutrition, extracurricular routine.',
          'Japa Maid: Newborn massage/bath, mother post-natal nutrition, newborn sleep care.',
          'Patient Care: Post-surgery recovery, mobility support, medication reminder, vital checks.',
          'Elderly Care: Senior companion, walking support, doctor visits, daily routine care.',
          'Driver: City navigation, vehicle cleaning, maintenance, safe driving etiquette.'
        ]),
        tags: JSON.stringify(['Service Scope', '8 Categories', 'Duties', 'Hindi', 'English']),
        order_index: 6
      },
      {
        id: 'LRN007',
        category: 'sourcingVerification',
        title: 'Candidate Background Verification & Vetting Standards',
        subtitle: 'SOP for unique Aadhaar validation, past employer checking, and police clearance',
        target_role: 'sourcing',
        script_english: 'Namaste. We are conducting a background check for [Candidate Name] for a domestic placement. Could you please confirm their previous employment duration and conduct?',
        script_hindi: 'Namaste ji. Hum Verified Maids se verification ke liye call kar rahe hain regarding [Candidate Name]. Kya aap confirm kar sakte hain inhone aapke yahan kab se kab tak kaam kiya aur inka behavior kaisa tha?',
        key_tip: 'Never place a candidate whose 12-digit Aadhaar number is duplicate or pending verification.',
        bullet_points: JSON.stringify([
          'Mandatory 12-digit Aadhaar number check against database uniqueness.',
          'At least 1 previous employer / reference call verification.',
          'Police verification form submission and status tracking in CRM.',
          'Basic hygiene, health demeanor, and language capability assessment.'
        ]),
        tags: JSON.stringify(['Sourcing', 'Verification', 'Aadhaar', 'Police Check', 'Hindi', 'English']),
        order_index: 7
      },
      {
        id: 'LRN008',
        category: 'fieldSop',
        title: 'Field Executive Visit & Candidate Drop Protocol',
        subtitle: 'Professional conduct for client house visits, physical agreement signing, and candidate introduction',
        target_role: 'executive',
        script_english: 'Hello Sir/Ma\'am, I am [Executive Name] from Verified Maids. I have accompanied [Candidate Name] for the trial joining. Here is the formal agreement and identity document for your verification.',
        script_hindi: 'Namaste Sir/Ma\'am, Main [Executive Name], Verified Maids se aaya/aayi hoon. Main [Candidate Name] ko trial joining ke liye accompany kar raha/rahi hoon. Ye hamara formal agreement aur candidate ka verification document hai for your check.',
        key_tip: 'Always be punctual, wear formal attire/ID card, and collect client physical signatures on the contract copy.',
        bullet_points: JSON.stringify([
          'Verify candidate identity before reaching client doorstep.',
          'Introduce candidate politely and review key duties with the client.',
          'Collect physical signatures on contract copy and upload photo to CRM.',
          'If payment collection task: Issue official receipt and update CRM immediately.'
        ]),
        tags: JSON.stringify(['Field SOP', 'Executive', 'Candidate Drop', 'Client Visit', 'Hindi', 'English']),
        order_index: 8
      },
      {
        id: 'LRN009',
        category: 'salesPitch',
        title: 'Candidate Trial & Joining Coordination SOP',
        subtitle: 'How to coordinate trials, manage client expectations, and close permanent joining smoothly',
        target_role: 'sales',
        script_english: 'We have scheduled the trial for [Candidate Name] on [Date & Time]. Please evaluate their core work over the 1-2 day trial. Once satisfied, our field executive will execute the agreement and candidate joins permanently.',
        script_hindi: 'Humne [Candidate Name] ka trial [Date & Time] ke liye schedule kiya hai. Aap 1-2 din unka basic kaam observe kar lijiye. Jaise hi aap fully satisfied ho jayein, hamara field executive agreement execute karega aur candidate permanently start karegi.',
        key_tip: 'Call the client on the evening of Day 1 of trial to gather quick feedback and resolve any initial minor adjustments.',
        bullet_points: JSON.stringify([
          'Confirm candidate location and travel route 2 hours before trial time.',
          'Inform client about candidate arrival via WhatsApp confirmation message.',
          'Collect Day 1 trial feedback proactively.',
          'Upon client confirmation, generate contract in CRM and collect 1st installment.'
        ]),
        tags: JSON.stringify(['Sales SOP', 'Trial Coordination', 'Closing', 'Hindi', 'English']),
        order_index: 9
      },
      {
        id: 'LRN010',
        category: 'objectionHandling',
        title: 'Client Replacement Request & Dispute Resolution SOP',
        subtitle: 'Handling unsatisfied clients with empathy and dispatching prompt replacement tickets',
        target_role: 'sales',
        script_english: 'I completely understand your concern, [Client Name]. Your comfort is our top priority. I am immediately logging a Priority Replacement Ticket in our CRM, and our sourcing team will share 2-3 verified profiles within 24-48 hours.',
        script_hindi: 'Main aapki pareshani bilkul samajh sakta/sakti hoon [Client Name] ji. Hamare liye aapka satisfaction sabse zaroori hai. Main turant CRM me Priority Replacement Ticket log kar raha/rahi hoon, aur hamari team 24-48 hours me aapko 2-3 verified profiles provide karegi.',
        key_tip: 'Never argue with an upset client. Acknowledge their issue, assure them of contract replacement guarantee, and act fast.',
        bullet_points: JSON.stringify([
          'Log exact client feedback reasons in CRM Ticket (e.g. Taste, Timings, Absence).',
          'Coordinate exit date of current candidate respectfully.',
          'Dispatch urgent requirement to Sourcing team.',
          'Keep client updated daily until new candidate trial commences.'
        ]),
        tags: JSON.stringify(['Dispute Resolution', 'Replacement SOP', 'Client Care', 'Hindi', 'English']),
        order_index: 10
      },
      {
        id: 'LRN011',
        category: 'salesPitch',
        title: 'Contract Renewal & Guarantee Extension SOP',
        subtitle: 'Proactive outreach 30 days before contract expiry for annual renewal and staff continuity',
        target_role: 'sales',
        script_english: 'Namaste [Client Name], hope [Candidate Name] is doing great at your home! Your 1-year contract is completing next month. To ensure uninterrupted service, replacement safety, and relationship manager support, we have initiated your annual renewal.',
        script_hindi: 'Namaste [Client Name] ji! Umeed hai [Candidate Name] aapke yahan bahut accha kaam kar rahi hain. Aapka 1-year contract next month complete ho raha hai. Continuous service support aur free replacement safety maintain rakhne ke liye humne aapka annual renewal initiate kiya hai.',
        key_tip: 'Highlight that renewing the contract protects them with replacement guarantee for the whole next year at zero hassle.',
        bullet_points: JSON.stringify([
          'Filter Expiring Contracts tab in CRM (30 days advance).',
          'Confirm candidate willingness to continue.',
          'Offer seamless 1-click renewal from CRM.',
          'Issue renewed contract certificate.'
        ]),
        tags: JSON.stringify(['Renewal SOP', 'Retention', 'Contract Extension', 'Hindi', 'English']),
        order_index: 11
      },
      {
        id: 'LRN012',
        category: 'sourcingVerification',
        title: 'Urgent Hire Sourcing & Fast Match SOP',
        subtitle: 'Step-by-step SOP for fulfilling urgent 24-48h client requirements from Ready-to-Place pool',
        target_role: 'sourcing',
        script_english: 'Namaste [Candidate Name]. We have an urgent requirement matching your expected salary and preferred locality in [Area]. Can you attend a trial tomorrow morning?',
        script_hindi: 'Namaste [Candidate Name] ji. Hamare paas aapki pasand ki location [Area] me urgent kaam aaya hai jo aapki salary expectations match karta hai. Kya aap kal subah trial ke liye ready hain?',
        key_tip: 'Always check "Ready to Place" candidates who are in close geographic radius to minimize travel fatigue and last-minute dropouts.',
        bullet_points: JSON.stringify([
          'Check Urgent Hires dashboard for newly broadcasted client demands.',
          'Filter candidates by Verified + Ready to Place status.',
          'Confirm candidate availability, transport route, and diet match before assignment.',
          'Click "Assign Candidate" in CRM to mark urgent requirement fulfilled.'
        ]),
        tags: JSON.stringify(['Urgent Hires', 'Fast Match', 'Sourcing SOP', 'Hindi', 'English']),
        order_index: 12
      },
      {
        id: 'LRN013',
        category: 'sourcingVerification',
        title: 'Candidate Blacklisting & Disciplinary Protocol',
        subtitle: 'When and how to permanently blacklist candidates in CRM (theft, forged Aadhaar, unauthorized absence)',
        target_role: 'sourcing',
        script_english: 'Attention: Candidate [Name] has been blacklisted due to verified policy breach. All active applications and placements are immediately suspended.',
        script_hindi: 'Dhyan de: Candidate [Name] ko policy violation ke karan blacklist kiya gaya hai. Inka koi bhi future placement ya client interview strictly prohibited hai.',
        key_tip: 'Blacklisting requires mandatory audit note submission detailing the specific evidence/police complaint.',
        bullet_points: JSON.stringify([
          'Reasons for Blacklisting: Forged Aadhaar, theft, violent behavior, intentional fraud.',
          'Click "Blacklist" on Candidate Profile and input mandatory detailed remarks.',
          'System automatically hides blacklisted profiles from client placement lists.',
          'Audit trail logs the admin/sourcing officer who executed the blacklist.'
        ]),
        tags: JSON.stringify(['Blacklisting', 'Compliance', 'Security SOP', 'Hindi', 'English']),
        order_index: 13
      },
      {
        id: 'LRN014',
        category: 'fieldSop',
        title: 'Field Cash/UPI Payment Collection & Instant Receipt SOP',
        subtitle: 'Rules for collecting 1st or 2nd installment at client home, issuing WhatsApp receipts, and zero discrepancy',
        target_role: 'executive',
        script_english: 'Thank you for the payment of ₹[Amount] towards [1st / 2nd Installment]. I have updated our CRM system and sent the official payment receipt directly to your WhatsApp.',
        script_hindi: 'Payment ke liye dhanyawad Sir/Ma\'am. ₹[Amount] ka payment hamare CRM system me update ho gaya hai aur official receipt aapke WhatsApp par bhej di gayi hai.',
        key_tip: 'Never accept cash without immediately generating the digital receipt in CRM on the spot.',
        bullet_points: JSON.stringify([
          'Open Contract Profile on mobile CRM and verify pending balance amount.',
          'Accept payment via Verified Maids Company QR / Bank Transfer / Cash.',
          'Click "Record 2nd Installment" or "Payment Receipt" to generate instant digital receipt.',
          'Share official receipt via WhatsApp to client within 2 minutes.'
        ]),
        tags: JSON.stringify(['Payment Collection', 'Receipt SOP', 'Field Executive', 'Hindi', 'English']),
        order_index: 14
      },
      {
        id: 'LRN015',
        category: 'fieldSop',
        title: 'Emergency Candidate Replacement Drop & Handover SOP',
        subtitle: 'How to smoothly conduct candidate replacement drops, take exit handover, and update CRM status',
        target_role: 'executive',
        script_english: 'Hello [Client Name], I have brought [New Candidate Name] as your verified replacement. Let us complete the handover and confirm the duty transition.',
        script_hindi: 'Namaste [Client Name] ji! Main [New Candidate Name] ko aapke replacement ke roop me le kar aaya/aayi hoon. Chaliye inko ghar ke daily routines aur responsibilities handover kar dete hain.',
        key_tip: 'Ensure the previous candidate has returned house keys/belongings and received any pro-rated salary for days worked.',
        bullet_points: JSON.stringify([
          'Verify that the previous candidate\'s due salary for actual days worked is settled by client.',
          'Introduce the new replacement candidate to the household routines.',
          'Update CRM Replacement Ticket status to "Handover Completed".',
          'Log executive field notes on the client and candidate profiles.'
        ]),
        tags: JSON.stringify(['Replacement Drop', 'Handover SOP', 'Field Executive', 'Hindi', 'English']),
        order_index: 15
      },
      {
        id: 'LRN016',
        category: 'objectionHandling',
        title: 'Convincing: "Why should I pay 50% 1st Installment before permanent joining?"',
        subtitle: 'How to explain the 1st installment commitment and candidate exclusive blocking to hesitant clients',
        target_role: 'sales',
        script_english: 'Sir/Ma\'am, the 50% 1st installment exclusively reserves this verified candidate for your home so she does not accept another client\'s offer. It also covers background documentation and our field executive accompaniment. If after the 1-2 day trial you are not satisfied, we provide alternative verified candidates or adjust the amount under our satisfaction guarantee.',
        script_hindi: 'Sir/Ma\'am, 50% 1st installment candidate ko exclusively aapke liye block karne ke liye hoti hai taaki wo kisi dusre client ka offer na le le. Sath hi isme field executive drop aur documentation included hota hai. Agar 1-2 din trial ke baad aap satisfied nahi hote, toh hum bina kisi extra charge ke dusri verified profile provide karte hain.',
        key_tip: 'Reassure the client that their money is 100% protected under our formal company receipt and replacement policy.',
        bullet_points: JSON.stringify([
          'Explain candidate reservation: Good candidates receive multiple offers daily.',
          'Highlight that payment is officially logged in CRM with an instant GST tax invoice.',
          'Emphasize that the 2nd installment is strictly payable ONLY after permanent joining.'
        ]),
        tags: JSON.stringify(['Advance Payment', '1st Installment', 'Convincing', 'Hindi', 'English']),
        order_index: 16
      },
      {
        id: 'LRN017',
        category: 'objectionHandling',
        title: 'Safety & Trust: "What if the staff steals or damages something in my house?"',
        subtitle: 'How to build complete confidence about background checks, police verification, and legal traceability',
        target_role: 'sales',
        script_english: 'Safety is our highest priority. Unlike local maids, every Verified Maids candidate undergoes 12-digit UIDAI Aadhaar authentication, permanent address verification, and police verification record filing. In addition, we execute a legal tripartite service agreement with complete identity records on file.',
        script_hindi: 'Sir/Ma\'am, safety hamari sabse pehli priority hai. Local maids ke opposite, Verified Maids ka har candidate 12-digit UIDAI Aadhaar verified hota hai, permanent address verify hota hai, aur police verification record file hota hai. Hamare paas legal agreement aur candidate ke complete biometric identity records maintain rehte hain.',
        key_tip: 'Remind the client that street brokers have zero records and disappear, whereas Verified Maids maintains permanent digital records.',
        bullet_points: JSON.stringify([
          '12-digit Aadhaar identity verification & past employer reference vetting.',
          'Police verification application record maintained in CRM.',
          'Full legal agreement establishing clear accountability and dispute framework.'
        ]),
        tags: JSON.stringify(['Safety', 'Theft Prevention', 'Police Verification', 'Hindi', 'English']),
        order_index: 17
      },
      {
        id: 'LRN018',
        category: 'objectionHandling',
        title: 'Negotiation: "Can I negotiate or reduce the candidate\'s monthly salary?"',
        subtitle: 'Explaining fair market compensation versus staff retention to prevent sudden maid dropouts',
        target_role: 'sales',
        script_english: 'While we always ensure competitive rates, keeping the salary at the fair market level guarantees the candidate stays long-term, arrives punctually, and does not look for another job. Underpaying staff by ₹1,000-2,000 often leads to sudden absenteeism or quitting within 2-3 weeks.',
        script_hindi: 'Sir/Ma\'am, hum hamesha fair market rate suggest karte hain. Agar candidate ko market se kam salary di jaye, toh wo 2-3 hafte me chhod kar chali jati hai ya roz chutti karti hai. Fair salary dene se candidate loyal rehti hai, timely aati hai, aur pure 1 saal bina chutti ke kaam karti hai.',
        key_tip: 'Frame fair salary as "Zero headache and long-term peace of mind for the family".',
        bullet_points: JSON.stringify([
          'Explain the correlation between fair compensation and long-term maid retention.',
          'Emphasize that the monthly salary goes 100% directly to the candidate\'s hands.',
          'Offer adjustments in work scope (e.g. reducing hours) rather than underpaying for heavy workloads.'
        ]),
        tags: JSON.stringify(['Salary Negotiation', 'Retention', 'Market Rates', 'Hindi', 'English']),
        order_index: 18
      },
      {
        id: 'LRN019',
        category: 'objectionHandling',
        title: 'Duty Boundaries: "Can the Cook also wash bathrooms and do heavy mopping?"',
        subtitle: 'How to explain hygiene standards, role dignity, and suggest all-rounder packages tactfully',
        target_role: 'sales',
        script_english: 'For food safety and hygiene, dedicated cooks typically handle kitchen meal preparation, chopping, and cooking vessels. Mixing heavy bathroom washing or floor scrubbing with cooking creates cross-contamination concerns. If you need both, we can either provide an All-Rounder Housekeeper or coordinate two specialized helpers.',
        script_hindi: 'Sir/Ma\'am, hygiene aur food safety ke liye dedicated cook sirf khana banana, vegetable chopping aur kitchen utensils dekhti hai. Cooking ke sath bathroom wash ya heavy pocha mix karne se hygiene issue hota hai. Agar aapko dono kaam chahiye, toh hum aapko ek trained All-Rounder provide kar sakte hain.',
        key_tip: 'Never make false promises on calls. Setting clean role boundaries prevents client-maid disputes on Day 2.',
        bullet_points: JSON.stringify([
          'Explain food hygiene and cross-contamination risks.',
          'Suggest the "All-Rounder Housekeeper" profile if client has a compact home.',
          'Clearly itemize agreed tasks on the client profile in CRM before dispatch.'
        ]),
        tags: JSON.stringify(['Duty Boundaries', 'Cook Hygiene', 'All Rounder', 'Hindi', 'English']),
        order_index: 19
      },
      {
        id: 'LRN020',
        category: 'objectionHandling',
        title: 'Trial Policy: "Can I get a 7-day or 10-day free trial first?"',
        subtitle: 'How to explain standard 1-2 day trials and reassure client with 365-day replacement protection',
        target_role: 'sales',
        script_english: 'Our standard trial is 1-2 days, which is ample time to assess punctuality, cooking taste, and basic demeanor. Candidates are full-time job seekers and cannot work 7-10 days without confirmation. However, once you confirm, our 1-year contract protects you with 100% free replacements for 365 days.',
        script_hindi: 'Sir/Ma\'am, 1-2 din ka trial candidate ke cooking taste, punctuality aur behavior samajhne ke liye kaafi hota hai. Candidates full-time job dhundh rahe hote hain aur 7-10 din bina confirmation ke nahi ruk sakte. Lekin confirm hone ke baad aapko pure 365 din free replacement protection milti hai.',
        key_tip: 'Highlight that 1-2 day trial gives immediate clarity, and 1-year replacement guarantee covers the entire year.',
        bullet_points: JSON.stringify([
          'Standard trial duration: 1 to 2 days maximum.',
          'Assure client that replacement guarantee protects them for full contract duration.',
          'Emphasize that field executive visits to formalize the agreement only after trial satisfaction.'
        ]),
        tags: JSON.stringify(['Trial Policy', 'Satisfaction Guarantee', 'Hindi', 'English']),
        order_index: 20
      },
      {
        id: 'LRN021',
        category: 'salesPitch',
        title: 'Pitching 24h Live-in Staff vs 10h Part-time Care',
        subtitle: 'How to pitch 24-hour live-in staff for infant care, post-natal recovery, and elderly assistance',
        target_role: 'sales',
        script_english: 'For infant childcare or elderly care, a 24-hour live-in helper is vastly superior to 10-hour day staff. It completely eliminates daily traffic delays, weather absenteeism, and provides continuous night-time support for bottle feeding or medication monitoring.',
        script_hindi: 'Baby care ya elderly patient care ke liye 24-hours live-in staff 10-hours staff se bahut zyada reliable rehta hai. Isme daily traffic ya barish ki vajah se chutti nahi hoti, aur raat ke time baby feeding ya emergency medicine support me family ko pura aaram rehta hai.',
        key_tip: 'Identify client pain points (e.g. working mother or bedridden parent) and highlight night-time peace of mind.',
        bullet_points: JSON.stringify([
          'Zero travel fatigue or daily transit delays.',
          'Round-the-clock emergency support for seniors or infants.',
          'Higher bonding and loyalty as staff resides as part of household support.'
        ]),
        tags: JSON.stringify(['24h Live-in', 'Baby Care', 'Elderly Care', 'Pitch', 'Hindi', 'English']),
        order_index: 21
      },
      {
        id: 'LRN022',
        category: 'salesPitch',
        title: 'Handling "I will think and tell" & Creating Positive Urgency',
        subtitle: 'How to follow up politely with hesitant clients and close the shortlisting on the same day',
        target_role: 'sales',
        script_english: 'Certainly [Client Name], please take your time to discuss with your family. Just to let you know, verified candidates with [specific skill/diet] in [Area] get placed very quickly. Would you like me to tentatively block her profile for your trial until 6 PM today?',
        script_hindi: 'Bilkul [Client Name] ji, aap family me discuss kar lijiye. Bas ek chota sa update dena tha ki [Area] me verified [Cook / Maid] ki demand bahut high rehti hai. Kya main inka profile aaj shaam 6 baje tak aapke trial ke liye tentatively block kar doon taaki ye kisi aur client ko na assign ho?',
        key_tip: 'Never sound pushy. Offer to "block the profile for a few hours" as a helpful favor to protect their booking.',
        bullet_points: JSON.stringify([
          'Acknowledge client need to discuss with spouse/family.',
          'Highlight scarcity of top-rated verified candidates in their specific locality.',
          'Give a specific deadline (e.g. 6 PM today) to lock the candidate profile.'
        ]),
        tags: JSON.stringify(['Closing', 'Follow-up', 'Urgency', 'Hindi', 'English']),
        order_index: 22
      },
      {
        id: 'LRN023',
        category: 'salesPitch',
        title: 'Post-Placement Day 7 & Day 30 Relationship Management SOP',
        subtitle: 'Structured check-in calls to ensure 100% client satisfaction and generate word-of-mouth referrals',
        target_role: 'sales',
        script_english: 'Hello [Client Name], this is your Relationship Manager from Verified Maids. It has been a week since [Candidate Name] joined your home. How is the cooking taste and daily timing? Is there anything we can help fine-tune?',
        script_hindi: 'Namaste [Client Name] ji! Main Verified Maids se aapka dedicated Relationship Manager baat kar raha hoon. [Candidate Name] ko join kiye 1 week ho gaya hai. Khane ka taste aur timings sab theek chal raha hai? Kya hume kisi cheez me fine-tune karne ki zaroorat hai?',
        key_tip: 'Proactive Day 7 check-ins catch 90% of minor adjustments before they turn into replacement requests.',
        bullet_points: JSON.stringify([
          'Check punctuality, food taste, hygiene, and candidate comfort.',
          'If minor feedback (e.g. less salt/spices), guide the maid directly on client preferences.',
          'If client is extremely happy, politely request a 5-star Google review or society referral.'
        ]),
        tags: JSON.stringify(['Relationship Management', 'Retention', 'Client Care', 'Hindi', 'English']),
        order_index: 23
      }
    ];

    console.log(`Upserting ${topics.length} comprehensive bilingual learning topics...`);

    for (const t of topics) {
      await pool.execute(
        `INSERT INTO learning_topics 
        (id, category, title, subtitle, target_role, script_english, script_hindi, key_tip, bullet_points, tags, order_index) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
          category = VALUES(category),
          title = VALUES(title),
          subtitle = VALUES(subtitle),
          target_role = VALUES(target_role),
          script_english = VALUES(script_english),
          script_hindi = VALUES(script_hindi),
          key_tip = VALUES(key_tip),
          bullet_points = VALUES(bullet_points),
          tags = VALUES(tags),
          order_index = VALUES(order_index),
          is_active = TRUE`,
        [
          t.id,
          t.category,
          t.title,
          t.subtitle,
          t.target_role,
          t.script_english,
          t.script_hindi,
          t.key_tip,
          t.bullet_points,
          t.tags,
          t.order_index
        ]
      );
    }

    console.log(`Successfully synced all ${topics.length} comprehensive bilingual learning topics in MySQL.`);
    process.exit(0);
  } catch (err) {
    console.error('Error setting up learning table:', err);
    process.exit(1);
  }
}

setupLearningTable();
