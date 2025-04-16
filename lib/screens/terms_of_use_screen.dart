import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final titleSize = size.width * 0.06;
    final sectionTitleSize = size.width * 0.045;
    final bodyTextSize = size.width * 0.035;
    final padding = size.width * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Use'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Use and User Agreement',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              'Effective Date: April 16, 2025',
              style: TextStyle(
                fontSize: bodyTextSize * 0.8,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              'Welcome to WhereWorks. By accessing or using the WhereWorks platform (the "Platform"), including our website and mobile applications, you agree to comply with and be bound by these Terms of Use and User Agreement ("Terms"). If you do not agree to these Terms, you may not use the Platform.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '1. Acceptance of Terms',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'By registering for, accessing, or using the Platform, you affirm that you are at least 18 years of age or the age of majority in your jurisdiction. You also affirm that you have the authority to enter into these Terms either personally or on behalf of an entity. If you are accessing the Platform on behalf of an organization, you warrant that you have the necessary authority to bind that organization to these Terms.\n\nThese Terms constitute a legally binding agreement between you and WhereWorks. It is your responsibility to read these Terms carefully before using the Platform. Your use of the Platform constitutes your acceptance of the Terms in full, and any future updates to them. If you do not agree to these Terms or any changes made to them in the future, you must stop using the Platform immediately.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '2. Use of the Platform',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'You may use the Platform to discover and browse workspaces, cafes, coworking spaces, and other venues suitable for work, study, or reading. The Platform allows you to submit reviews, ratings, photos, and engage with location-based features such as maps, navigation, and venue details. You may also use filters and search tools to customize your browsing experience.\n\nYou agree not to misuse the Platform or use it in any unlawful manner. Prohibited uses include but are not limited to: attempting to gain unauthorized access to the Platform, interfering with other users\' access or experience, or using automated means to access or harvest data from the Platform. WhereWorks reserves the right to investigate and take legal action against users who violate these restrictions.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '3. Account Registration and Security',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'To access certain features of the Platform, you may be required to register and create an account. During registration, you agree to provide current, accurate, and complete information. You also agree to update this information to maintain its accuracy. Failure to do so may result in the suspension or termination of your account.\n\nYou are responsible for maintaining the confidentiality of your account credentials and are fully responsible for all activities that occur under your account. If you suspect unauthorized access or any breach of security, you must notify WhereWorks immediately. We reserve the right to disable accounts that are found to be compromised or misused.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '4. Content Submission',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'You retain ownership of any content you submit to the Platform, such as reviews, photos, ratings, and written feedback. However, by submitting content, you grant WhereWorks a perpetual, irrevocable, non-exclusive, royalty-free, worldwide, transferable, and sublicensable license to use, reproduce, distribute, display, and modify your content for purposes related to the Platform, including marketing, analytics, and improving user experience.\n\nYou agree not to post or submit content that is false, misleading, defamatory, abusive, obscene, offensive, or that infringes upon any intellectual property rights or applicable laws. WhereWorks reserves the right to moderate, remove, or refuse any content at its sole discretion, with or without notice.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '5. Intellectual Property',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'All materials on the Platform, including but not limited to trademarks, logos, design, graphics, text, code, and user interface, are the intellectual property of WhereWorks or its licensors and are protected under applicable intellectual property laws. You agree not to reproduce, distribute, modify, or create derivative works from any portion of the Platform without prior written permission.\n\nUnauthorized use of any intellectual property belonging to WhereWorks may result in legal action. You may not use our trademarks, service marks, or trade dress in any manner that implies affiliation, endorsement, or sponsorship without express written permission from WhereWorks.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '6. Platform Availability and Modifications',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'WhereWorks endeavors to provide reliable and continuous access to the Platform but does not guarantee that the service will be uninterrupted or error-free. From time to time, access may be interrupted for maintenance, upgrades, or unforeseen issues. We are not liable for any disruptions or unavailability of the Platform.\n\nWe reserve the right to modify, suspend, or discontinue any part of the Platform at any time without prior notice. This includes the removal of features, functionality, or content. You agree that WhereWorks shall not be liable for any such modifications or discontinuation of services.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '7. Disclaimer of Warranties',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'The Platform is provided on an "as is" and "as available" basis, without warranties of any kind. WhereWorks disclaims all express or implied warranties, including but not limited to warranties of merchantability, fitness for a particular purpose, non-infringement, and suitability for your needs.\n\nWe do not warrant the accuracy, completeness, reliability, or availability of any information or content made available through the Platform. We do not endorse or guarantee the quality or availability of third-party venues or services listed on the Platform. Your reliance on any content or listings is solely at your own risk.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '8. Limitation of Liability',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'To the fullest extent permitted by law, WhereWorks shall not be liable for any direct, indirect, incidental, special, consequential, or punitive damages, including but not limited to loss of profits, data, business opportunities, or goodwill, arising from your use of or inability to use the Platform, even if we have been advised of the possibility of such damages.\n\nIn jurisdictions that do not allow the exclusion or limitation of liability for certain types of damages, our liability shall be limited to the greatest extent permitted by law. In any case, WhereWorks\' aggregate liability for all claims shall not exceed the amount you have paid to us in the preceding six months, if any.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '9. Indemnification',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'You agree to indemnify and hold harmless WhereWorks, its officers, directors, employees, contractors, agents, affiliates, and licensors from and against any claims, demands, damages, obligations, losses, liabilities, costs or debts, and expenses (including attorney\'s fees) resulting from:\n\n• Your use of and access to the Platform;\n• Your violation of any provision of these Terms;\n• Any claim that your content caused damage to a third party.\n\nThis indemnification obligation will survive the termination or expiration of your relationship with WhereWorks and your use of the Platform. We reserve the right to assume the exclusive defense and control of any matter otherwise subject to indemnification by you, in which event you will cooperate with us in asserting any available defenses.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '10. Governing Law and Dispute Resolution',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'These Terms shall be governed by and construed in accordance with the laws of the Kingdom of Thailand, without regard to its conflict of law principles. All disputes, claims, or controversies arising out of or relating to these Terms or your use of the Platform shall be subject to the exclusive jurisdiction of the courts located in Bangkok, Thailand.\n\nYou agree that before initiating any legal action, you will attempt to resolve any disputes informally by contacting WhereWorks. If a resolution is not reached within thirty (30) days, you may proceed with formal dispute resolution. You waive any objections to the venue, jurisdiction, or forum based on convenience or otherwise.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '11. Termination',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'WhereWorks reserves the right to terminate or suspend your access to the Platform at any time and for any reason, including but not limited to a breach of these Terms. Such termination may be immediate and without prior notice. Upon termination, your right to use the Platform will immediately cease.\n\nAll provisions of these Terms that by their nature should survive termination shall continue to apply, including but not limited to ownership provisions, warranty disclaimers, indemnity, and limitations of liability. Termination does not relieve you of any obligation to pay any fees or charges incurred prior to termination.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '12. Changes to These Terms',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'WhereWorks may modify or revise these Terms from time to time. When changes are made, we will update the "Effective Date" at the top of this document and provide notice via the Platform or other means. You are responsible for reviewing the updated Terms to stay informed.\n\nContinued use of the Platform after the posting of changes constitutes your binding acceptance of such changes. If you do not agree to the revised Terms, you must stop using the Platform immediately.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              '13. Contact Us',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'If you have questions, feedback, or concerns about these Terms, you may contact us via email at support@whereworks.app. We will make every reasonable effort to respond to inquiries in a timely and professional manner.\n\nYou may also contact us via the contact form available on the Platform. For legal notices, please ensure that communications are clearly marked as such and sent to our designated legal contact.\n\nBy using the Platform, you acknowledge that you have read, understood, and agree to be bound by these Terms. You further agree that you are solely responsible for your use of the Platform and expressly waive any and all claims against WhereWorks, its affiliates, officers, directors, and employees, to the extent permitted by applicable law.',
              style: TextStyle(height: 1.5, fontSize: bodyTextSize),
            ),
            SizedBox(height: size.height * 0.03),
          ],
        ),
      ),
    );
  }
} 