import { BaseEntity } from './../../shared';
import { AttachmentGroup } from '../attachment-group';
import { Attachment } from '../attachment';

export class Institution implements BaseEntity {
    constructor(
        public id?: number,
        public name?: string,
        public type?: string,
        public businessRegNo?: string,
        public industry?: string,
        public address?: string,
        public phone?: string,
        public fax?: string,
        public email?: string,
        public website?: string,
        public createdBy?: string,
        public createdDate?: any,
        public lastModifiedBy?: string,
        public lastModifiedDate?: any,
        public parent?: BaseEntity,
        public attachmentGroup?: AttachmentGroup,
        public attachments?: Attachment[]
    ) {
    }
}
