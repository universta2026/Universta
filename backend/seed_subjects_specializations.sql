-- Dummy data: 10 subjects and their specializations (all published).
-- Safe to run twice: rows whose slug already exists are skipped.

INSERT INTO subjects (id, name, slug, description, icon_key, status, display_order, published_at) VALUES
 (gen_random_uuid(), 'Computer Science & IT', 'computer-science-it', 'Software, AI, data and the systems that run the modern world.', 'code', 'published', 1, now()),
 (gen_random_uuid(), 'Business & Management', 'business-management', 'How organisations work - strategy, money, people and markets.', 'briefcase', 'published', 2, now()),
 (gen_random_uuid(), 'Engineering', 'engineering', 'Design and build the machines, structures and energy systems we rely on.', 'cog', 'published', 3, now()),
 (gen_random_uuid(), 'Health & Medicine', 'health-medicine', 'Care for people and communities - nursing, public health and more.', 'heart', 'published', 4, now()),
 (gen_random_uuid(), 'Law', 'law', 'Understand legal systems and learn to argue, advise and protect.', 'scale', 'published', 5, now()),
 (gen_random_uuid(), 'Arts, Design & Architecture', 'arts-design-architecture', 'Shape the spaces, images and ideas that define how we live.', 'pen-tool', 'published', 6, now()),
 (gen_random_uuid(), 'Social Sciences', 'social-sciences', 'Study people, societies and the forces that shape human behaviour.', 'users', 'published', 7, now()),
 (gen_random_uuid(), 'Natural Sciences', 'natural-sciences', 'Explore life, matter and the natural world through research.', 'flask', 'published', 8, now()),
 (gen_random_uuid(), 'Hospitality & Tourism', 'hospitality-tourism', 'Run hotels, events and travel experiences around the world.', 'utensils', 'published', 9, now()),
 (gen_random_uuid(), 'Media & Communication', 'media-communication', 'Tell stories and reach audiences across news, film and digital media.', 'megaphone', 'published', 10, now())
ON CONFLICT (slug) DO NOTHING;

INSERT INTO specializations (id, subject_id, name, slug, description, status, display_order, published_at)
SELECT gen_random_uuid(), s.id, v.name, v.slug, v.description, 'published', v.ord, now()
FROM (VALUES
 ('computer-science-it', 'Artificial Intelligence',   'artificial-intelligence',   'Machine learning, neural networks and intelligent systems.', 1),
 ('computer-science-it', 'Data Science',              'data-science',              'Turn large datasets into insight with statistics and code.', 2),
 ('computer-science-it', 'Cyber Security',            'cyber-security',            'Protect systems, networks and data from attack.', 3),
 ('computer-science-it', 'Software Engineering',      'software-engineering',      'Design, build and maintain reliable software.', 4),

 ('business-management', 'Finance',                   'finance',                   'Investment, banking and corporate financial management.', 1),
 ('business-management', 'Marketing',                 'marketing',                 'Understand customers and build brands that grow.', 2),
 ('business-management', 'Business Analytics',        'business-analytics',        'Use data to guide business decisions.', 3),
 ('business-management', 'International Business',    'international-business',    'Manage trade and operations across borders.', 4),

 ('engineering', 'Mechanical Engineering',            'mechanical-engineering',    'Machines, engines and manufacturing systems.', 1),
 ('engineering', 'Civil Engineering',                 'civil-engineering',         'Bridges, buildings and infrastructure.', 2),
 ('engineering', 'Electrical Engineering',            'electrical-engineering',    'Power, electronics and communication systems.', 3),
 ('engineering', 'Robotics',                          'robotics',                  'Build and program autonomous machines.', 4),

 ('health-medicine', 'Nursing',                       'nursing',                   'Hands-on patient care and clinical practice.', 1),
 ('health-medicine', 'Public Health',                 'public-health',             'Prevent disease and improve community health.', 2),
 ('health-medicine', 'Pharmacy',                      'pharmacy',                  'Medicines, drug safety and patient advice.', 3),

 ('law', 'International Law',                         'international-law',         'Law between states, treaties and global institutions.', 1),
 ('law', 'Corporate Law',                              'corporate-law',             'Contracts, mergers and business regulation.', 2),

 ('arts-design-architecture', 'Architecture',         'architecture',              'Design buildings and the spaces around them.', 1),
 ('arts-design-architecture', 'Graphic Design',       'graphic-design',            'Visual communication for print and screen.', 2),

 ('social-sciences', 'Psychology',                    'psychology',                'The science of mind and behaviour.', 1),
 ('social-sciences', 'Economics',                     'economics',                 'How markets, money and policy shape societies.', 2),
 ('social-sciences', 'Sociology',                     'sociology',                 'Study groups, institutions and social change.', 3),

 ('natural-sciences', 'Biology',                      'biology',                   'Living organisms from cells to ecosystems.', 1),
 ('natural-sciences', 'Chemistry',                    'chemistry',                 'The structure and behaviour of matter.', 2),

 ('hospitality-tourism', 'Hotel Management',          'hotel-management',          'Operate hotels and guest services.', 1),
 ('hospitality-tourism', 'Tourism Management',        'tourism-management',        'Plan and manage destinations and travel.', 2),

 ('media-communication', 'Journalism',                'journalism',                'Research, report and publish the news.', 1),
 ('media-communication', 'Digital Media',             'digital-media',             'Create content for online platforms.', 2)
) AS v(subject_slug, name, slug, description, ord)
JOIN subjects s ON s.slug = v.subject_slug
ON CONFLICT (slug) DO NOTHING;
