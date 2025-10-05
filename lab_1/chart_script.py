# Create detailed ER diagram for library management system
diagram_code = """
erDiagram
    READER {
        int reader_id PK
        string last_name
        string first_name
        string middle_name
        string reader_type
        string phone
        string email
        date registration_date
    }
    
    BOOK {
        int book_id PK
        string title
        string isbn
        int publication_year
        int pages
        int copies_total
        int copies_available
        int category_id FK
    }
    
    AUTHOR {
        int author_id PK
        string last_name
        string first_name
        string middle_name
        int birth_year
        string country
    }
    
    CATEGORY {
        int category_id PK
        string name
        string description
    }
    
    LOAN {
        int loan_id PK
        int reader_id FK
        int book_id FK
        date loan_date
        date due_date
        date return_date
        string status
    }
    
    FINE {
        int fine_id PK
        int loan_id FK
        decimal amount
        date fine_date
        boolean paid
    }
    
    AUTHORSHIP {
        int book_id "PK,FK"
        int author_id "PK,FK"
    }
    
    %% Relationships with Crow's Foot notation
    READER ||--o{ LOAN : "берет"
    BOOK ||--o{ LOAN : "выдается"
    CATEGORY ||--o{ BOOK : "содержит"
    LOAN ||--|| FINE : "порождает"
    AUTHOR ||--o{ AUTHORSHIP : "создает"
    BOOK ||--o{ AUTHORSHIP : "написана"
"""

# Create the mermaid diagram using the helper function
png_path, svg_path = create_mermaid_diagram(
    diagram_code, 
    'library_er_diagram.png', 
    'library_er_diagram.svg',
    width=1400,
    height=1000
)

print(f"ER diagram saved as: {png_path} and {svg_path}")