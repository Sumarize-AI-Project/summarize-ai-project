import json
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, ServerSelectionTimeoutError

class MongoDBManager:
    """Quản lý kết nối và thao tác với MongoDB"""
    
    # Danh sách các collection có sẵn
    COLLECTIONS = {
        "basic_identifiers": "basic_identifiers",
        "content_collection": "content_collection",
        "file_info": "file_info",
        "metadata_collection": "metadata_collection",
        "nlp_data_collection": "nlp_data_collection",
        "startup_log": "startup_log",
        "system_collection": "system_collection"
    }
    
    # Mapping: key trong JSON -> collection + danh sách field cần lấy
    FIELD_MAPPING = {
        "basic_identifiers": {
            "collection": "basic_identifiers",
            "fields": ["_id", "document_id", "journal_code", "processing_label"]
        },
        "file_info": {
            "collection": "file_info",
            "fields": ["document_id", "file_name", "local_path", "file_size_kb", "page_count"]
        },
        "metadata": {
            "collection": "metadata_collection",
            "fields": ["document_id", "title", "authors", "publish_year", "keywords_author"]
        },
        "content": {
            "collection": "content_collection",
            "fields": ["document_id", "full_text"]
        },
        "nlp_data": {
            "collection": "nlp_data_collection",
            "fields": ["document_id", "extracted_text", "ai_summary", "extracted_entities", "embedding_vector"]
        },
        "system": {
            "collection": "system_collection",
            "fields": ["document_id", "status", "created_at", "updated_at"]
        }
    }
    
    def __init__(self, uri="mongodb://localhost:27017/", db_name="local"):
        """Khởi tạo kết nối MongoDB"""
        self.uri = uri
        self.db_name = db_name
        self.client = None
        self.db = None
        self.connect()
    
    def connect(self):
        """Kết nối tới MongoDB"""
        try:
            self.client = MongoClient(self.uri, serverSelectionTimeoutMS=5000)
            self.db = self.client[self.db_name]
            self.client.admin.command('ping')
            print(f"✅ Kết nối MongoDB thành công! (Database: {self.db_name})")
            return True
        except (ConnectionFailure, ServerSelectionTimeoutError) as e:
            print(f"❌ Lỗi kết nối MongoDB: {e}")
            return False
    
    def close(self):
        """Đóng kết nối MongoDB"""
        if self.client is not None:
            self.client.close()
            print("🔌 Đã đóng kết nối MongoDB")
    
    def get_collection(self, collection_name):
        """Lấy collection theo tên"""
        if collection_name not in self.COLLECTIONS:
            print(f"⚠️ Collection '{collection_name}' không tồn tại!")
            return None
        if self.db is not None:
            return self.db[collection_name]
        return None
    
    def insert_one(self, collection_name, document):
        """Chèn một document vào collection"""
        col = self.get_collection(collection_name)
        if col is not None:
            result = col.insert_one(document)
            print(f"✅ Đã chèn vào {collection_name}: {result.inserted_id}")
            return result.inserted_id
        return None
    
    def insert_many(self, collection_name, documents):
        """Chèn nhiều documents vào collection"""
        col = self.get_collection(collection_name)
        if col is not None and documents:
            result = col.insert_many(documents)
            print(f"✅ Đã chèn {len(documents)} records vào {collection_name}")
            return result.inserted_ids
        return None
    
    def find(self, collection_name, query=None, limit=0):
        """Tìm kiếm documents trong collection"""
        col = self.get_collection(collection_name)
        if col is not None:
            query = query or {}
            results = list(col.find(query).limit(limit) if limit > 0 else col.find(query))
            print(f"📊 Tìm thấy {len(results)} records trong {collection_name}")
            return results
        return []
    
    def find_one(self, collection_name, query=None):
        """Tìm một document trong collection"""
        col = self.get_collection(collection_name)
        if col is not None:
            query = query or {}
            result = col.find_one(query)
            if result:
                print(f"📌 Tìm thấy 1 record trong {collection_name}")
            return result
        return None
    
    def update_one(self, collection_name, query, update_data):
        """Cập nhật một document"""
        col = self.get_collection(collection_name)
        if col is not None:
            result = col.update_one(query, {"$set": update_data})
            print(f"✏️ Đã cập nhật {result.modified_count} record trong {collection_name}")
            return result
        return None
    
    def delete_one(self, collection_name, query):
        """Xóa một document"""
        col = self.get_collection(collection_name)
        if col is not None:
            result = col.delete_one(query)
            print(f"🗑️ Đã xóa {result.deleted_count} record trong {collection_name}")
            return result
        return None
    
    def delete_many(self, collection_name, query=None):
        """Xóa nhiều documents"""
        col = self.get_collection(collection_name)
        if col is not None:
            query = query or {}
            result = col.delete_many(query)
            print(f"🗑️ Đã xóa {result.deleted_count} records trong {collection_name}")
            return result
        return None
    
    def count(self, collection_name):
        """Đếm số documents trong collection"""
        col = self.get_collection(collection_name)
        if col is not None:
            count = col.count_documents({})
            print(f"📈 Collection '{collection_name}' có {count} documents")
            return count
        return 0
    
    def list_all_collections(self):
        """Liệt kê tất cả collections"""
        if self.db is not None:
            collections = self.db.list_collection_names()
            print("📋 Danh sách collections:")
            for col in collections:
                count = self.db[col].count_documents({})
                print(f"   • {col}: {count} documents")
            return collections
        return []
    
    def show_collection_schema(self):
        """Hiển thị schema của từng collection (khi nào lấy những field nào)"""
        print("\n📊 Schema của từng collection:")
        for json_key, mapping_info in self.FIELD_MAPPING.items():
            col_name = mapping_info["collection"]
            fields = mapping_info["fields"]
            print(f"\n   📌 {col_name}:")
            print(f"      Fields: {', '.join(fields)}")
    
    def upload_from_jsonl(self, jsonl_file_path, mapping=None):
        """Nạp dữ liệu từ file JSONL vào các collection, chỉ lấy các field cần thiết"""
        if mapping is None:
            mapping = self.FIELD_MAPPING
        
        # Chuẩn bị buffer cho từng collection
        buffers = {col_name: [] for col_name in self.COLLECTIONS.values()}
        print(f"🔄 Đang bóc tách dữ liệu từ: {jsonl_file_path}...")
        
        try:
            with open(jsonl_file_path, 'r', encoding='utf-8') as f:
                for line_num, line in enumerate(f, 1):
                    if not line.strip():
                        continue
                    
                    try:
                        data_block = json.loads(line)
                        
                        # Lặp qua mapping để lấy chỉ các field cần thiết
                        for json_key, mapping_info in mapping.items():
                            if json_key in data_block:
                                col_name = mapping_info["collection"]
                                fields_to_extract = mapping_info["fields"]
                                
                                # Chỉ lấy các field được định nghĩa
                                filtered_doc = {
                                    field: data_block[json_key].get(field)
                                    for field in fields_to_extract
                                    if field in data_block[json_key]
                                }
                                
                                if filtered_doc:  # Chỉ thêm nếu có field
                                    buffers[col_name].append(filtered_doc)
                                
                    except json.JSONDecodeError:
                        print(f"⚠️ Dòng {line_num} không phải JSON hợp lệ.")
            
            # Nạp vào các collection
            print("🚀 Đang phân loại và nạp vào các collection...")
            for col_name, data_list in buffers.items():
                if data_list:
                    self.insert_many(col_name, data_list)
            
            print("\n✨ Xong! Dữ liệu đã được nạp vào các collection với các field cụ thể.")
        
        except FileNotFoundError:
            print(f"❌ Không tìm thấy file: {jsonl_file_path}")


# Các hàm tiện lợi cho việc sử dụng nhanh
def upload_structured_jsonl_to_mongodb(jsonl_file_path, db_name="data_mining"):
    """Hàm cũ để tương thích ngược"""
    manager = MongoDBManager(db_name=db_name)
    manager.upload_from_jsonl(jsonl_file_path)
    manager.close()


if __name__ == "__main__":
    # Ví dụ sử dụng
    manager = MongoDBManager(db_name='local')
    
    # 1. Liệt kê tất cả collections
    manager.list_all_collections()
    
    # 2. Đếm documents trong từng collection
    print("\n📊 Thống kê collections:")
    for col_name in manager.COLLECTIONS.keys():
        manager.count(col_name)
    
    # 3. Nạp từ file JSONL (nếu có)
    # manager.upload_from_jsonl("test.jsonl")
    
    # 4. Ví dụ tìm kiếm
    # results = manager.find("basic_identifiers", limit=5)
    # for doc in results:
    #     print(doc)
    
    manager.close()